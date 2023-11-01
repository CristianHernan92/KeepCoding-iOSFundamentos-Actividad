import UIKit

class HeroeTableViewCell: UITableViewCell {
    
    weak var navigationControllerReference: UINavigationController? = nil
    var heroId: String? = nil
    var transformationsDataList: [CellData]? 
    
    //MARK: OUTLETS
    @IBOutlet weak var descriptionOfCell: UILabel!
    @IBOutlet weak var titleOfCell: UILabel!
    @IBOutlet weak var imageOfCell: UIImageView!
    
    //MARK: ACTIONS
    @IBAction func showHeroDetail(_ sender: Any) {
            //creamos el array de tipo "CellData" en donde pondremos los datos que ya contiene la vista para usarlos en la vista de detalle
            var heroDetailData : [CellData] = []
            heroDetailData.append(CellData.init(title: self.titleOfCell.text!, description: self.descriptionOfCell.text!, image: CellDataImage(URL: nil, UIImage: self.imageOfCell.image!),heroId: nil))
        
            //si transformationsDataList está vacía quiere decir que la tableview se usara para mostrar la lista de heroes, sino la de transformaciones
            if (self.transformationsDataList == []){
                    let DragonBallZNetworkModel = DragonBallZNetworkModel()
                    //llamamos a la api que trae todas las transformaciones según el id del heroe
                    DragonBallZNetworkModel.getHeroeTransformations(heroId: heroId!){data, error in
                        guard error == nil else {
                            print("Error: \(String(describing: error))")
                            return
                        }
                        
                        //creamos el array de tipo "CellData" que contrendrá los datos para las celdas de la tabla cuando se use para mostrar la lista de transformaciones
                        for HeroTransformation in (data as [HeroTransformation]) {
                            self.transformationsDataList!.append(CellData.init(title: HeroTransformation.name, description: HeroTransformation.description, image: CellDataImage(URL: HeroTransformation.photo, UIImage: nil),heroId: nil))
                        }
                        
                        DispatchQueue.main.async {
                            self.navigationControllerReference!.pushViewController(
                                TableViewController(navigatorTitle: self.titleOfCell.text!, hidesBackButtonOfNavigator: false, cellDataList: heroDetailData,nameOfCellToUse: "HeroeDetailTableViewCell", identifierOfCellToUse: "HeroDetailCell", heigthOfCell: 725.0, transformationsDataList: self.transformationsDataList),
                                animated: true)
                        }
                    }
            }
            else{
                DispatchQueue.main.async {
                    self.navigationControllerReference!.pushViewController(
                        TableViewController(navigatorTitle: self.titleOfCell.text!, hidesBackButtonOfNavigator: false, cellDataList: heroDetailData,nameOfCellToUse: "HeroeDetailTableViewCell", identifierOfCellToUse: "HeroDetailCell", heigthOfCell: 725.0, transformationsDataList: self.transformationsDataList),
                        animated: true)
                }
            }
    }
}
