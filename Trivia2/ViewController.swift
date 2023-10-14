import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var answer4: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var questionsCntLabel: UILabel!
    @IBOutlet weak var questionLabel: UITextView!
    
    var correctAnswer: String = ""
    var cnt: Int = 0
    var correctCnt: Int = 0
    var questions: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.layer.cornerRadius = 10
        fetchTriviaQuestions()
    }
    
    func fetchTriviaQuestions() {
        TriviaQuestionService.shared.fetchTriviaQuestions { [weak self] questions, error in
            if let questions = questions {
                self?.questions = questions
//                print(self?.questions)
                if !questions.isEmpty {
                    self?.displayQuestion(question: questions.randomElement()!)
                } else {
                    print("No trivia questions received.")
                }
            } else if let error = error {
                print("Error fetching trivia questions: \(error.localizedDescription)")
            }
        }
    }
    
    func decodeHTMLEntities(_ text: String) -> String {
        var decodedText = text
        let entities = [
                "&rsquo;": "’",
                "&ldquo;": "“",
                "&rdquo;": "”",
                "&hellip;": "…",
                "&quot;": "\"", // Handle &quot; as a double quote
                // Add more entities as needed
            ]
        
        for (entity, character) in entities {
            decodedText = decodedText.replacingOccurrences(of: entity, with: character)
        }
        
        return decodedText
    }

    
    func displayQuestion(question: Question) {
        correctAnswer = question.correctAnswer
        var answerChoices = question.incorrectAnswers
        answerChoices.append(question.correctAnswer)
        answerChoices.shuffle()
        let decodedText = decodeHTMLEntities(question.question)
        questionLabel.text = decodedText
            
        answer1.setTitle(answerChoices[0], for: .normal)
        answer2.setTitle(answerChoices[1], for: .normal)
        answer3.setTitle(answerChoices[2], for: .normal)
        answer4.setTitle(answerChoices[3], for: .normal)
        
        questionLabel.text = question.question
        cnt += 1
        questionsCntLabel.text = "Questions: \(cnt) / 5"
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        let selectedAnswer = sender.currentTitle
        var isCorrect = false
        
        if selectedAnswer == correctAnswer {
            correctCnt += 1
            isCorrect = true
        }
        
        let alertTitle = isCorrect ? "Correct" : "Incorrect"
        let alertMessage = isCorrect ? "Your answer is correct!" : "Your answer is incorrect."
        
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )
        
        let continueAction = UIAlertAction(
            title: "Continue",
            style: .default,
            handler: { _ in
                if self.cnt == 5 {
                    // Game over, show final score alert
                    self.showFinalScore()
                } else if self.cnt < 5, !self.questions.isEmpty, self.cnt < self.questions.count {
                    self.displayQuestion(question: self.questions.randomElement()!)
                }
            }
        )
        
        alertController.addAction(continueAction)
        present(alertController, animated: true, completion: nil)
    }

    func showFinalScore() {
        let alertController = UIAlertController(
            title: "Game Over",
            message: "Final score: \(correctCnt) / 5",
            preferredStyle: .alert
        )
        
        let restartAction = UIAlertAction(
            title: "Restart",
            style: .default,
            handler: { _ in
                self.cnt = 0
                self.correctCnt = 0
                self.displayQuestion(question: self.questions.randomElement()!)
                print("restarting!!!!!!")
            }
        )
        
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }

}
