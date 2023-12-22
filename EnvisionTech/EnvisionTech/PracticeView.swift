//
//  PracticeView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/29/23.
//

import SwiftUI

struct Row: View {
    @AppStorage("theme") var currtheme: String = "Light"
    @Binding var isSelected: Bool
    @Binding var stage: Stage
    var text: String

    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.easeInOut(duration: isSelected ? 0.1 : 0.5)) {
                    isSelected.toggle()
                }
            }) {
                ZStack (alignment: .leading){
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 80)
                        .foregroundStyle(isSelected ? Color("\(currtheme)-symbol") : Color("\(currtheme)-button"))
                        .shadow(color: Color(.sRGBLinear, white: currtheme == "Dark" ? 0.1: 0, opacity: currtheme == "Dark" ? 0.7: 0.1), radius: 5, x: 10, y: 10)
                    
                    Text(text)
                        .font(.title2)
                        .bold()
                        .padding(.horizontal, 25)
                }
            }
            .disabled(stage != .answering)
        }
        .padding(10)
    }
}

enum Stage: String {
    case answering
    case submitted
    case explanation
}

struct PracticeView: View {
    @AppStorage("theme") var currtheme: String = "Light"
    @State var stage: Stage = .answering
    
    @State private var scale: CGFloat = 0.0
    @State private var opacity: CGFloat = 0.0
    @State private var textScale: CGFloat = 0.0
    @State var dismissOpacity: CGFloat = 0.0
    
    @State private var questionIndex = 0

    @State private var questions: [Question] = []
    
    var body: some View {
        if !(questions.isEmpty) {
            if !(questions.indices.contains(questionIndex)) {
                let correct = questions.filter{ $0.result == true }.count
                VStack {
                    Text("Quiz Complete!")
                    Text("Score: \(correct)/\(questions.count)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .background(Color("\(currtheme)-background"))
                .font(.largeTitle.lowercaseSmallCaps())
                .bold()
            }
            else {
                let currentQuestion = questions[questionIndex]
                VStack {
                    Section {
                        displayContent(currentQuestion: currentQuestion)
                    } footer: {
                        displayFooter(currentQuestion: currentQuestion)
                    }
                }
                .background(Color("\(currtheme)-background"))
                .overlay(
                    displayOverlay(currentQuestion: currentQuestion)
                )
            }
        } else {
            displayLoading()
        }
    }
    
    func displayLoading() -> some View {
        ProgressView("Loading...")
            .task({
                await fetchQuestions()
            })
    }
    
    func displayContent(currentQuestion: Question) -> some View {
        VStack {
            displayQuestion(currentQuestion: currentQuestion)
            displayOptions(currentQuestion: currentQuestion)
        }
        .foregroundStyle(Color("\(currtheme)-buttonText"))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
    
    func displayQuestion(currentQuestion: Question) -> some View {
        Text(currentQuestion.question)
            .foregroundStyle(Color("\(currtheme)-plainText"))
            .font(.largeTitle)
            .bold()
            .minimumScaleFactor(0.5)
    }
    
    func displayOptions(currentQuestion: Question) -> some View {
        ForEach(currentQuestion.answers.indices, id: \.self) { i in
            let q = currentQuestion.answers[i]
            
            Row(isSelected: .init(
                get: {currentQuestion.currentSelection == q},
                set: {if $0 {questions[questionIndex].currentSelection = q} else { questions[questionIndex].currentSelection = nil} }
            ), stage: $stage, text: "\(i+1). \(q)")
        }

    }
    
    func displayFooter(currentQuestion: Question) -> some View {
        HStack {
            let answeredCount = questions.filter{ $0.result != nil }.count
            Text("\(answeredCount+1) of \(questions.count)")
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .font(.headline)
                .bold()
            circleProgress()
            Spacer()
            submitButton(currentQuestion: currentQuestion)
        }
        .padding(.horizontal, 50)
    }
    
    func circleProgress() -> some View {
        ForEach(questions.indices, id: \.self) { i in
            let ans = questions[i].result
            if let ans = ans {
                Circle()
                    .frame(width: 12, height: 20)
                    .foregroundStyle(ans == true ? Color("\(currtheme)-symbol") : .gray)
            }
            else {
                Circle()
                    .stroke(lineWidth: 1.5)
                    .frame(width: 10)
                    .foregroundStyle(Color("\(currtheme)-plainText"))
            }
        }
    }
    
    func submitButton(currentQuestion: Question) -> some View {
        Button(action: {updateQuestions(currentQuestion: currentQuestion)}) {
            Text("Submit")
                .font(.title2.lowercaseSmallCaps())
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(currentQuestion.currentSelection == nil ? .gray : Color("\(currtheme)-symbol"))
                )
            
        }
        .disabled(currentQuestion.currentSelection == nil || stage == .submitted)
    }
    
    func updateQuestions(currentQuestion: Question) -> Void {
        questions[questionIndex].result = currentQuestion.correct == currentQuestion.currentSelection ? true : false
        stage = .submitted
        withAnimation(.easeInOut(duration: 0.25)){
            opacity = 0.5
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0)) {
            scale = 15
        }
    }
    
    func displayOverlay(currentQuestion: Question) -> some View {
        VStack(spacing: 0) {
            if stage == .submitted {
                displayResult(currentQuestion: currentQuestion)
                dismissText()
            }
            else if stage == .explanation {
                displayExplanation(currentQuestion: currentQuestion)
                dismissText()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(currtheme == "Dark" ? Color.white.opacity(opacity) : Color.black.opacity(opacity))
        .onTapGesture {
            resetIfSubmitted()
        }
    }
    
    func dismissText() -> some View {
        Text("Tap to Dismiss")
            .foregroundStyle(Color("\(currtheme)-plainText"))
            .font(.title)
            .bold()
            .opacity(dismissOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).delay(3.0)) {
                    dismissOpacity = 1
                }
            }
    }
    
    func displayResult(currentQuestion: Question) -> some View {
        Image(systemName: currentQuestion.result == true ? "checkmark" : "xmark")
            .scaleEffect(scale)
            .bold()
            .foregroundStyle(currentQuestion.result == true ? .green : .red)
            .frame(maxHeight: .infinity, alignment: .center)
    }
    
    func displayExplanation(currentQuestion: Question) -> some View {
        VStack(spacing: 0) {
            Text("Explanation")
                .font(.title2)
                .foregroundStyle(Color("\(currtheme)-plainText"))
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Rectangle().foregroundStyle(Color("\(currtheme)-background"))
                        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                )
            
            Text(currentQuestion.explanation)
                .fontDesign(.rounded)
                .foregroundStyle(Color("\(currtheme)-buttonText"))
                .font(.system(size: 20))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle().foregroundStyle(Color("\(currtheme)-button"))
                        .clipShape(.rect(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                )
        }
        .scaleEffect(textScale)
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    func resetIfSubmitted() -> Void {
        dismissOpacity = 0
        if stage == .submitted {
            scale = 0
            
            if questions[questionIndex].result == true {
                newQuestion()
            } else {
                stage = .explanation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0)) {
                    textScale = 1
                }
            }
        }
        else if stage == .explanation {
            textScale = 0
            newQuestion()
        }
    }
    
    func fetchQuestions() async {
        guard let url = URL(string: "http://192.168.0.132:5000/practice") else {
            return
        }
                
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([QuestionBody].self, from: data)
            self.questions = decodedData.map( {Question(body: $0)} )
        } catch {
            print("Error fetching or decoding data: \(error)")
        }
    }
    
    func newQuestion() -> Void {
        opacity = 0
        questionIndex += 1
        stage = .answering
    }
}

struct Question {
    var body: QuestionBody
    var question: String
    var explanation: String
    var correct: String
    var answers: [String]
    
    var currentSelection: String? = nil
    var result: Bool?
    
    init(body: QuestionBody) {
        self.body = body
        self.question = body.question
        self.explanation = body.explanation
        self.answers = body.incorrect
        self.correct = body.correct

        self.answers.append(body.correct)
        self.answers.shuffle()
    }
}

struct QuestionBody: Decodable {
    var question: String
    var explanation: String
    var incorrect: [String]
    var correct: String
}

#Preview {
    PracticeView()
}
