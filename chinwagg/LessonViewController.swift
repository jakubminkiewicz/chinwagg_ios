//
//  LessonViewController.swift
//  chinwagg
//
//  Created by Jakub Minkiewicz on 12/03/2020.
//  Copyright © 2020 Jakub Minkiewicz. All rights reserved.
//

import UIKit
import Speech

class LessonViewController: UIViewController {
    
    var languageUsed = "en_GB"
    var quiz = false
    
    private let audioEngine = AVAudioEngine()
    private var audioPlayer = AVAudioPlayer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var timer = Timer()
    
    var words_pl = ["jabłko","jak się masz","cześć","stół","dlaczego", "dziecko", "dososły", "wiewiórka", "komputer", "będzie", "mysz", "kot", "pies", "ptak", "jedzenie", "bar", "kawa", "kubek", "produkt", "szczęśliwy", "miłość", "koncert", "źródło", "woda", "butelka"]
    var words_en_GB = ["apple","how are you","hi","table","why","child","adult","squirrel","computer", "will", "mouse", "cat", "dog", "bird", "food", "pub", "coffee", "mug", "product", "happy", "love", "concert", "source", "water", "bottle"]
    
    var words: [String] = []
    
    var timerCounter = 30
    
    var stringOfSpokenWords: [String] = []
    
    var counter = 0
    
    @IBOutlet weak var wordDisplay: UILabel!
    @IBOutlet weak var talkWordBtnOutlet: UIButton!
    @IBOutlet weak var timerDisplay: UILabel!
    
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        timerCounter -= 1
        timerDisplay.text = "⏳ \(timerCounter)"
        if timerCounter == 0 {
            timer.invalidate()
            timerDisplay.text = "You got \(counter) points!"
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recognitionTask = nil
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest = nil
        }
    }
    
    func playSound() {
        
        changeAudioSessionToPlayback()
        audioPlayer.delegate = self
        audioPlayer.play()
        
    }
    
    func changeAudioSessionToPlayback() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("\(error)")
        }
    }
    
    func synthesizeWord(word: Int, speed: Float) {
        
        talkWordBtnOutlet.isEnabled = false
        
        let utterance = AVSpeechUtterance(string: words[word])
        print("This is the word: \(wordDisplay.text!)")
        utterance.voice = AVSpeechSynthesisVoice(language: languageUsed)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * speed
        
        synthesizer.speak(utterance)
    }
    
    @IBAction func talkWorkBtn(_ sender: Any) {
        changeAudioSessionToPlayback()
        synthesizeWord(word: counter, speed: 1)
    }
    
    @IBAction func talkSlowBtn(_ sender: Any) {
        changeAudioSessionToPlayback()
        synthesizeWord(word: counter, speed: 0.45)
    }
    
    func startRecording() throws {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageUsed))
        
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .mixWithOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            print("LISTENING...")
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        print("Does this device support on device transcripts for \(languageUsed): \(speechRecognizer?.supportsOnDeviceRecognition ?? false)")
        
        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? true{
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }
        
        talkWordBtnOutlet.isEnabled = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if result != nil {
                if let result = result {
                    DispatchQueue.main.async {
                        let transcribedString = result.bestTranscription.formattedString.lowercased()
                        if self.stringOfSpokenWords.isEmpty {
                            self.stringOfSpokenWords.append(transcribedString)
                        } else if self.stringOfSpokenWords[self.stringOfSpokenWords.count-1] != transcribedString {
                            self.stringOfSpokenWords.append(transcribedString)
                        }
                        print(self.stringOfSpokenWords)
                        print ("These are the words said: \(self.stringOfSpokenWords)")
                        //insert check here
                        if transcribedString.contains(String(self.wordDisplay!.text!)){
                            self.counter = self.counter + 1
                            if self.quiz == false {
                                if self.counter >= self.words.count {
                                    self.wordDisplay.text = "Well done!"
                                } else {
                                    self.wordDisplay.text = self.words[self.counter]
                                }
                            } else {
                                if self.counter == 5 {
                                    self.wordDisplay.text = "Well done!"
                                    let numberOfQuestions: Double = 5.0
                                    let tries: Double = Double(self.stringOfSpokenWords.count)
                                    let scoreFinal: Double = Double((numberOfQuestions / tries) * 100.00)
                                    self.timerDisplay.text = "Your score is \(String(format: "%.1f", scoreFinal))%"
                                } else {
                                    self.wordDisplay.text = self.words[self.counter]
                                }
                            }
                            
                            self.playSound()
                        }
                    }
                }
            }
            if error != nil {
                print("\(String(describing: error))")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        synthesizer.delegate = self
        
        requestTranscribePermissions()
        
        if languageUsed == "pl" {
            words = words_pl.shuffled()
        } else if languageUsed == "en_GB"  {
            words = words_en_GB.shuffled()
        }
        
        if quiz == false {
            startTimer()
        }
        
        wordDisplay.text = words[0]
        
        let sound = Bundle.main.path(forResource: "ding", ofType: "mp3")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        } catch {
            print(error)
        }
        
        synthesizeWord(word: counter, speed: 1)
        
    }
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBAction func micButton(_ sender: Any, forEvent event: UIEvent) {
        do {
            try startRecording() }
        catch {
            print("Error has accured")
        }
    }
    
    static func shake(view: UIView, for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            view.transform = CGAffineTransform(translationX: translation, y: 0)
        }

        propertyAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)

        propertyAnimator.startAnimation()
    }
}

extension LessonViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("TEXT TO SPEECH DONE!")
        do {
            try startRecording()
        } catch {
            print("\(error)")
        }
    }
    
}

extension LessonViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("SOUND PLAYED! \(flag)")
        
        if counter < words.count {
            synthesizeWord(word: counter, speed: 1)
        } else {
            print("null")
        }
    }
}
