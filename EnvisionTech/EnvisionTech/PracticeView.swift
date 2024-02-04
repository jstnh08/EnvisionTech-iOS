//
//  PracticeView.swift
//  EnvisionTech
//
//  Created by Justin Hudacsko on 11/29/23.
//

import SwiftUI

struct Row: View {
    @Binding var isSelected: Bool
    @Binding var stage: Stage
    var text: String
    
    let opacityGray = Color.gray.opacity(0.9)
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.easeInOut(duration: isSelected ? 0.1 : 0.5)) {
                    isSelected.toggle()
                }
            }) {
                ZStack (alignment: .leading){
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 75)
                        .foregroundStyle(isSelected ?.blue : .white)
                        .shadow(radius: 3, x: 5, y: 5)
                    
                    HStack(spacing: 12) {
                        Circle()
                            .stroke(isSelected ? .clear : opacityGray, lineWidth: 1.5)
                            .fill(isSelected ? .white : .clear)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("A")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(isSelected ? .blue : opacityGray)
                            )
                        
                        Text(text)
                            .foregroundStyle(isSelected ? .white : opacityGray)
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
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
                PracticeEndView(correct: correct, incorrect: questions.count-correct)
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
                .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                .overlay(
                    displayOverlay(currentQuestion: currentQuestion)
                )
                .preferredColorScheme(.light)
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
        VStack(alignment: .leading) {
            displayQuestion(currentQuestion: currentQuestion)
            displayOptions(currentQuestion: currentQuestion)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
    
    func displayQuestion(currentQuestion: Question) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Question \(questionIndex+1) of \(questions.count)")
                .foregroundStyle(.gray.opacity(0.7))
                .fontWeight(.regular)
                .font(.body.smallCaps())
            
            HStack(spacing: 5) {
                ForEach(questions.indices, id: \.self) { i in
                    let ans = questions[i].result
                    if let ans = ans {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 5)
                            .frame(width: 40, height: 5)
                            .foregroundStyle(ans == true ? .blue.opacity(0.7) : .gray.opacity(0.5))
                    }
                    else {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(lineWidth: 0.3)
                            .frame(width: 40, height: 5)
                    }
                }
            }
            
            Text(currentQuestion.question)
                .foregroundStyle(.black)
                .font(.title)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .padding(.top)
        }
        .padding()
    }
    
    func displayOptions(currentQuestion: Question) -> some View {
        VStack(spacing: 0) {
            ForEach(currentQuestion.answers.indices, id: \.self) { i in
                let q = currentQuestion.answers[i]
                
                Row(isSelected: .init(
                    get: {currentQuestion.currentSelection == q},
                    set: {if $0 {questions[questionIndex].currentSelection = q} else { questions[questionIndex].currentSelection = nil} }
                ), stage: $stage, text: "\(q)")
            }
        }
    }
    
    func displayFooter(currentQuestion: Question) -> some View {
        HStack {
            submitButton(currentQuestion: currentQuestion)
        }
        .padding(.horizontal, 50)
    }
    
    func submitButton(currentQuestion: Question) -> some View {
        Button(action: {updateQuestions(currentQuestion: currentQuestion)}) {
            Text("Submit")
                .font(.title2.lowercaseSmallCaps())
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 105)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundStyle(currentQuestion.currentSelection == nil ?
                             LinearGradient(
                                colors: [.gray.opacity(0.6)],
                                startPoint: .bottom,
                                endPoint: .bottom
                             ) : LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                             )
                        )
                        .shadow(radius: 2, x: 2, y: 2)
                )
                .padding(.bottom)
            
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
        .background(Color.black.opacity(opacity))
        .onTapGesture {
            resetIfSubmitted()
        }
    }
    
    func dismissText() -> some View {
        Text("Tap to Dismiss")
            .foregroundStyle(.white)
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
        Text(currentQuestion.explanation)
            .lineSpacing(5)
            .font(.title3)
            .fontDesign(.rounded)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.blue.opacity(0.5), lineWidth: 7.5)
                    .fill(.white)
                    .shadow(color: .blue, radius: 3)
            )
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity, alignment: .center)
            .scaleEffect(textScale)
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
        guard let url = URL(string: "http://192.168.0.137:5000/practice") else {
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

struct QuizGaugeStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.1, to: 0.9 * configuration.value)
                .stroke(.blue.opacity(0.8), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(90))
 
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(.gray.opacity(0.25), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(90))
            
            configuration.currentValueLabel
        }
        .frame(width: 300, height: 300)
    }
}

struct PracticeEndView: View {
    var correct: Int
    var incorrect: Int
    
    @State private var quizScore = 0.0
    @State private var scale: CGFloat = 0.0
    
    func labelText(label: String, size: CGFloat) -> Text {
        Text(label)
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(.blue.opacity(0.8))
    }
    
    func infoRectangle(systemName: String, value: String) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .shadow(radius: 3, x: 3, y: 3)
            .frame(height: 120)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: systemName)
                        .font(.largeTitle)
                    
                    Text(value)
                        .font(.title2)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                }
                    .foregroundStyle(.blue.opacity(0.8))
            )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 35) {
                displayText()
                displayGauge()
                infoRectangles()
                quizButton()
            }
            .frame(maxHeight: .infinity)
            .padding()
            .background(Color(red: 240/255, green: 240/255, blue: 240/255))
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    quizScore = Double(correct)/Double(correct+incorrect) * 100
                } completion: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0)) {
                        scale = 1
                    }
                }
            }
        }
    }
    
    func displayText() -> some View {
        Text("Quiz Complete!")
            .font(.largeTitle)
            .fontDesign(.rounded)
            .foregroundStyle(.blue.opacity(0.8))
            .bold()
    }
    
    func displayGauge() -> some View {
        ZStack(alignment: .bottom) {
            Gauge(value: quizScore, in: 0...100) {
                Image(systemName: "gauge.medium")
                    .font(.system(size: 50.0))
            } currentValueLabel: {
                (labelText(label: "\(Int(quizScore))", size: 85) + labelText(label: "%", size: 55))
                    .scaleEffect(scale)
            }
            .gaugeStyle(QuizGaugeStyle())
        }
        .scaleEffect(0.95)
        .padding()
    }
    
    func infoRectangles() -> some View {
        HStack(spacing: 22) {
            infoRectangle(systemName: "clock.arrow.circlepath", value: "2:40")
            infoRectangle(systemName: "checkmark", value: "\(correct)")
            infoRectangle(systemName: "xmark", value: "\(incorrect)")
        }
        .padding(.horizontal)
    }
    
    func quizButton() -> some View {
        NavigationStack {
            NavigationLink(destination: PracticeView()) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.blue.opacity(0.8))
                    .padding(.horizontal)
                    .frame(height: 70)
                    .overlay(Text("Start new quiz").font(.title3).foregroundColor(.white).bold())
                    .clipped()
                    .shadow(radius: 3, x: 5, y: 5)
            }
        }
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
