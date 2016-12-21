import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var clickButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tap counts per second
        let allCountStream = clickButton.rx.tap         // --tap-tap------tap-tap-tap-->
            .buffer(timeSpan: 1.0,
                    count: 20,
                    scheduler: MainScheduler.instance)  // -[1, 1]-[]-[]-[]-[1, 1, 1]-->
            .filter { !$0.isEmpty }                     // -[1, 1]----------[1, 1, 1]-->
            .map { $0.count }                           // ---2-----------------3------>
        
        // show current score
        allCountStream
            .subscribe(onNext: { (n) in
                print("current score: \(n)/s")
                var message: String
                
                switch n {
                case 1...4:
                    message = "素人"
                case 5...8:
                    message = "凡人"
                case 9...12:
                    message = "達人"
                case 13...15:
                    message = "超人"
                default:
                    message = "名人"
                }
                
                message += ": \(n)/s"
                
                Observable.of(message)
                    .bindTo(self.resultLabel.rx.text)
                    .addDisposableTo(self.disposeBag)
            })
            .addDisposableTo(disposeBag)

        // show high score
        // TODO: can i use reduce instead of scan?
        allCountStream
            .scan(0, accumulator: { (acc, n) -> Int in
                acc > n ? acc : n
            })                                          // ---2--------3--------3------>
            .subscribe(onNext: { (n) in
                print("high score: \(n)/s")
                let message = "\(n)/s"
                
                Observable.of(message)
                    .bindTo(self.highScoreLabel.rx.text)
                    .addDisposableTo(self.disposeBag)
            })
            .addDisposableTo(disposeBag)
    }
}
