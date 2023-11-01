import UIKit

final class LoginViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK: Actions
    @IBAction func LoginButtonAction(_ sender: UIButton) {
        let DragonBallZNetworkModel = DragonBallZNetworkModel()
        DragonBallZNetworkModel.login(email: EmailTextField.text!, password: PasswordTextField.text!) { error in
                guard error==nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
            
                //hacemos la llamada a la base de datos trayendo toda la lista de los heroes
                DragonBallZNetworkModel.getHeroesList{data, error in
                    guard error == nil else {
                        print("Error: \(String(describing: error))")
                        return
                    }
                    
                    //creamos el array de tipo "CellData" que contrendrá los datos para las celdas de la tabla
                    var cellDataList : [CellData] = []
                    for Hero in (data as [Hero]) {
                        cellDataList.append(CellData.init(title: Hero.name, description: Hero.description, image: CellDataImage(URL: Hero.photo, UIImage: nil), heroId: Hero.id))
                    }
                    
                    //creamos y mostramos la tableview con el listado de heroes
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(
                            TableViewController(navigatorTitle: "Heroes", hidesBackButtonOfNavigator: true, cellDataList: cellDataList,nameOfCellToUse: "HeroeTableViewCell", identifierOfCellToUse: "HeroCell", heigthOfCell: 125.0,transformationsDataList: []),
                            animated: true)
                    }
            }
        }
    }
}
