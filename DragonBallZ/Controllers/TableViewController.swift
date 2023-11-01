import UIKit

final class TableViewController: UITableViewController {
    
    let navigatorTitle: String
    let hidesBackButtonOfNavigator : Bool
    let nameOfCellToUse : String
    let identifierOfCellToUse : String
    let cellDataList: [CellData]
    let heigthOfCell: CGFloat
    let transformationsDataList: [CellData]?
    
    init(navigatorTitle: String,hidesBackButtonOfNavigator: Bool,cellDataList: [CellData],nameOfCellToUse: String,identifierOfCellToUse : String,heigthOfCell: CGFloat,transformationsDataList: [CellData]?) {
        self.navigatorTitle = navigatorTitle
        self.hidesBackButtonOfNavigator = hidesBackButtonOfNavigator
        self.nameOfCellToUse = nameOfCellToUse
        self.identifierOfCellToUse = identifierOfCellToUse
        self.cellDataList = cellDataList
        self.heigthOfCell = heigthOfCell
        self.transformationsDataList = transformationsDataList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = hidesBackButtonOfNavigator
        navigationItem.title = navigatorTitle
        
        //registramos la celda personalizada con el identificador que le hayamos puesto
        let nib = UINib(nibName: nameOfCellToUse, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifierOfCellToUse)
    }
    
    //MARK: CANTIDAD CELDAS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataList.count
    }
    
    //MARK: DATOS CELDAS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return (
            (nameOfCellToUse == "HeroeTableViewCell") ? returnHeroeTableViewCellFilled()
            :
            (nameOfCellToUse == "HeroeDetailTableViewCell") ? returnHeroeDetailTableViewCellFilled()
            :
            UITableViewCell()
        )
        
        //
        
        func returnHeroeTableViewCellFilled() -> HeroeTableViewCell{
            //instanciamos la celda peronalizada que registramos más arriba en la tabla y lo casteamos al tipo de dicha celda para poder luego asignarles valor a sus atributos
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierOfCellToUse, for: indexPath) as! HeroeTableViewCell
            cell.heroId = cellDataList[indexPath.row].heroId
            cell.titleOfCell.text = cellDataList[indexPath.row].title
            cell.descriptionOfCell.text = cellDataList[indexPath.row].description
            cell.transformationsDataList = transformationsDataList
                
            let task = URLSession.shared.dataTask(with: cellDataList[indexPath.row].image.URL!) { (data, response, error) in
                        guard error == nil else {
                            print("Error: \(String(describing: error))")
                            return
                        }
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                            print("Response Error: \(String(describing: response))")
                            return
                        }
                        guard let data else {
                            print("No data error: \(String(describing: "El dato no es correcto"))")
                            return
                        }
                        DispatchQueue.main.async {
                            cell.imageOfCell.image = UIImage(data: data)
                        }
            }
            task.resume()
                    
            //pasamos la referencia del "NavigationController" para que la celda pueda manejarla
            cell.navigationControllerReference = self.navigationController
                    
            return cell
        }
        
        //
        
        func returnHeroeDetailTableViewCellFilled() -> HeroeDetailTableViewCell{
            //instanciamos la celda peronalizada que registramos más arriba en la tabla y lo casteamos al tipo de dicha celda para poder luego asignarles valor a sus atributos
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierOfCellToUse, for: indexPath) as! HeroeDetailTableViewCell
            cell.titleOfCell.text = cellDataList[indexPath.row].title
            cell.descriptionOfCell.text = cellDataList[indexPath.row].description
            cell.imageOfCell.image = cellDataList[indexPath.row].image.UIImage
                    
            //pasamos la referencia del "NavigationController" para que la celda pueda manejarla
            cell.navigationControllerReference = self.navigationController
            
            //si la lista de transformaciones está vacía o es nil ocultamos el botón de transformaciones
            if(transformationsDataList == [] || transformationsDataList == nil){
                cell.buttonOfTransformations.isEnabled = false
                cell.buttonOfTransformations.isHidden = true
            }
            else{
                cell.transformationsDataList = transformationsDataList!
            }
                    
            return cell
        }
    }
    
    //MARK: ALTURA CELDAS
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heigthOfCell
    }
}

//struct CellData 
struct CellData: Equatable {
    let title: String
    let description: String
    let image: CellDataImage
    var heroId: String?
}
struct CellDataImage: Equatable{
    let URL: URL?
    let UIImage:UIImage?
}
