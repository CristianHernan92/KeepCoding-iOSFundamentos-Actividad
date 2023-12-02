import UIKit

//MARK: -CLASS-

final class Login: UIViewController {
    @IBOutlet private weak var EmailTextField: UITextField!
    @IBOutlet private weak var PasswordTextField: UITextField!
    @IBAction private func LoginButtonAction(_ sender: UIButton) {
        login(email: EmailTextField.text, password: PasswordTextField.text) {
            self.getHeroesList() { data in
                DispatchQueue.main.async {
                    self.showHeroTable(navigationController: self.navigationController, data: data)
                }
            }
        }
    }
}

//MARK: -PROTOCOLS AND EXTENSIONS-

private protocol LoginMethodsProtocol{
    func login(email: String?, password: String?,completion: @escaping ()->Void)
    func getHeroesList(completion: @escaping ([Hero])->Void)
    func showHeroTable(navigationController: UINavigationController?,data: [Hero])
}

extension Login:LoginMethodsProtocol{
    fileprivate func login(email: String?, password: String?,completion: @escaping ()->Void) {
        DragonBallZNetworkModel.login(email: email!, password: password!) {
            completion()
        }
    }
    fileprivate func getHeroesList(completion: @escaping ([Hero])->Void) {
        DragonBallZNetworkModel.getHeroesList{data in
            completion(data)
        }
    }
    fileprivate func showHeroTable(navigationController: UINavigationController?,data: [Hero]) {
        DispatchQueue.main.async {
            navigationController?.showHeroTable(with: data)
        }
    }
}
