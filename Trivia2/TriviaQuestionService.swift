//
//  TriviaQuestionService.swift
//  Trivia2
//
//  Created by Yernar Sadybekov on 10/13/23.
//

import Foundation

struct Question: Decodable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
}

struct TriviaData: Decodable {
    let responseCode: Int
    let results: [Question]
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

class TriviaQuestionService {
    static let shared = TriviaQuestionService()
    
    func fetchTriviaQuestions(completion: @escaping ([Question]?, Error?) -> Void) {
        let apiUrl = URL(string: "https://opentdb.com/api.php?amount=100&difficulty=easy&type=multiple")
        
        let task = URLSession.shared.dataTask(with: apiUrl!) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
//                        print(jsonString)
                        if let dict = jsonString.toJSON() as? [String: AnyObject] {
                            if let list = dict["results"] as? [[String: Any]] {
                                var qList = [Question]()
                                for i in 0 ... list.count - 1 {
                                    let question = list[i]
//                                    print(question)
//                                    print(question["question"])
//                                    print(question["correct_answer"])
                                    let Q = Question(question: question["question"] as! String, correctAnswer: question["correct_answer"] as! String, incorrectAnswers: question["incorrect_answers"] as! [String])
                                    qList.append(Q)
                                }
//                                print(qList)
                                completion(qList, nil)
                            }
                        }
                    }
//                    print(json["results"])
                } catch {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
