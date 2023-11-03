import UIKit
import SnapKit

class ViewController: UIViewController {

    //MARK:  Label
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    //MARK: textfield
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Number"
        textField.layer.cornerRadius = 15
        textField.backgroundColor = .white
        textField.textColor = .black
        return textField
    }()

    //MARK: Generate Button
    private lazy var generateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.titleLabel?.text = "Generate"
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(generateButtonPressed), for: .touchUpInside)
        return button

    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.isHidden = false

        return activityIndicatorView
    }()

    //MARK: view

    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }

    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }

//MARK: Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setupConstraints()
    }
//MARK: Set up Views
    private func setUpViews() {
        [label, generateButton, textField].forEach {
            view.addSubview($0)
        }
    }

    //MARK: setup consstaints
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(250)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(40)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        generateButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(40)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
    }

//MARK: Actions
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""

        while password != passwordToUnlock {
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)

            DispatchQueue.main.sync { [weak self] in
                self?.label.text = password
            }
        }
        DispatchQueue.main.sync {
            self.textField.isSecureTextEntry = false
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    @objc func generateButtonPressed() {
        activityIndicatorView.startAnimating()
        guard let inputText = textField.text else { return }
        DispatchQueue.global().async { [weak self] in
            self?.bruteForce(passwordToUnlock: inputText)
        }
    }
}

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }

    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
                               : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    return str
}



