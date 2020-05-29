//
//  StopWatchViewController.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import UIKit

protocol StopWatchViewControllerDelegate: class {
    func viewDidLoad()
    func mainButtonTapped()
    func secondaryButtonTapped()
}

final class StopWatchViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!

    var viewModel: StopWatchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()

        viewModel?.viewDidLoad()
    }
}

// MARK: - IBActions
extension StopWatchViewController {
    @IBAction func mainButtonTapped(_ sender: Any) {
        viewModel?.mainButtonTapped()
    }


    @IBAction func secondaryButtonTapped(_ sender: Any) {
        viewModel?.secondaryButtonTapped()
    }
}

// MARK: - Set Up Methods
private extension StopWatchViewController {
    //MARK: - Setup Methods
    func setUp() {
        setUpLabels()
        setUpButtons()
        navigationBar()
    }

    func setUpLabels() {
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: timeLabel.font.pointSize, weight: .semibold)
        timeLabel.text = "00:00,00";
    }

    func setUpButtons() {
        mainButton.setTitle("Start", for: .normal)
        secondaryButton.setTitle("Lap", for: .normal)
        secondaryButton.isEnabled = false

        mainButton.backgroundColor = .lightGray
        mainButton.layer.cornerRadius = 14
        mainButton.layer.borderWidth = 2
        mainButton.layer.borderColor = UIColor.black.cgColor

        secondaryButton.backgroundColor = .lightGray
        secondaryButton.layer.cornerRadius = 14
        secondaryButton.layer.borderWidth = 2
        secondaryButton.layer.borderColor = UIColor.black.cgColor
    }

    func navigationBar() {
        self.title = "Timer";
    }
}

// MARK: - StopWatchViewModelDelegate
extension StopWatchViewController: StopWatchViewModelDelegate {
    func viewModel(_ viewModel: StopWatchViewModelType, stateDidChange state: StopWatchViewModelState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .initialized:
                break
            case .ready:
                break
            case .running:
                self?.mainButton.setTitle("Stop", for: .normal)
                self?.secondaryButton.isEnabled = true
            case .stopped:
                self?.mainButton.setTitle("Start", for: .normal)
                self?.secondaryButton.setTitle("Reset", for: .normal)
            case .resetting:
                self?.secondaryButton.setTitle("Lap", for: .normal)
                self?.secondaryButton.isEnabled = false
            case .trackingLap:
                break
            }
        }
    }

    func viewModel(_ viewModel: StopWatchViewModelType, updateTimer time: String) {
        DispatchQueue.main.async { [weak self] in
            self?.timeLabel.text = time
        }
    }

    func viewModel(_ viewModel: StopWatchViewModelType, trackLap time: String) {
        DispatchQueue.main.async { [weak self] in
            //TODO: Update table view
            print("Tracked Lap Time: \(time)")
        }
    }
}
