//
//  MenuViewController.swift
//  chinwagg
//
//  Created by Jakub Minkiewicz on 01/05/2020.
//  Copyright © 2020 Jakub Minkiewicz. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //nill
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "polishLevel1",
            let destinationVC = segue.destination as? LessonViewController {
            destinationVC.languageUsed = "pl"
        }
        
        if segue.identifier == "englishLevel1",
            let destinationVC = segue.destination as? LessonViewController {
            destinationVC.languageUsed = "en_GB"
        }
        
        if segue.identifier == "polishLevel1Quiz",
            let destinationVC = segue.destination as? LessonViewController {
            destinationVC.languageUsed = "pl"
            destinationVC.quiz = true
        }
        
        if segue.identifier == "englishLevel1Quiz",
            let destinationVC = segue.destination as? LessonViewController {
            destinationVC.languageUsed = "en_GB"
            destinationVC.quiz = true
        }
    }
    


}
