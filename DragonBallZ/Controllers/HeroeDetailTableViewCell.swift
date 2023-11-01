import UIKit

class HeroeDetailTableViewCell: UITableViewCell {
    
    weak var navigationControllerReference: UINavigationController? = nil
    var transformationsDataList: [CellData] = []
    
    //MARK: OUTLETS
    @IBOutlet weak var titleOfCell: UILabel!
    @IBOutlet weak var descriptionOfCell: UILabel!
    @IBOutlet weak var imageOfCell: UIImageView!
    @IBOutlet weak var buttonOfTransformations: UIButton!
    
    //MARK: ACTIONS
    @IBAction func transformationsButtonDidTap(_ sender: Any) {
        //creamos y mostramos la tableview con el listado de transformaciones 
        DispatchQueue.main.async {
            self.navigationControllerReference?.pushViewController(
                TableViewController(navigatorTitle: "Transformaciones", hidesBackButtonOfNavigator: false, cellDataList: self.transformationsDataList,nameOfCellToUse: "HeroeTableViewCell", identifierOfCellToUse: "HeroCell", heigthOfCell: 125.0, transformationsDataList: nil),
                animated: true)
        }
    }
}
