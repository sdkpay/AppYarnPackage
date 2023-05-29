
import UIKit

final class FakeViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Это тестовый режим\nТут происходит авторизация в мобильном приложении банка"
        label.font = .bodi3
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        titleLabel
            .add(toSuperview: view)
            .centerInSuperview(.horizontal)
            .centerInSuperview(.vertical)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: 20)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: 20)
    }
}
