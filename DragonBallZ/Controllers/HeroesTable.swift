import UIKit

//MARK: -PROTOCOLS-

private protocol HeroesTableMethodsProtocol{
    func registerCell()
    func configurations()
    func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell
    func height() -> CGFloat
    func showHeroDetailTable(id:String,name:String,description:String,photo:URL)
}

//MARK: -CLASS-

final class HeroesTable: UITableViewController {
    private let heroesList: [Hero]
    
    init(heroesList: [Hero])
    {
        self.heroesList = heroesList
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -EXTENSIONS-

extension HeroesTable {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        configurations()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = prepareAndReturnCell(indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showHeroDetailTable(
            id: self.heroesList[indexPath.row].id,
            name: self.heroesList[indexPath.row].name,
            description: self.heroesList[indexPath.row].description,
            photo: self.heroesList[indexPath.row].photo)
    }
}

extension HeroesTable:HeroesTableMethodsProtocol{
    fileprivate func registerCell(){
        let nib = UINib(nibName: "Cell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    fileprivate func configurations(){
        navigationItem.hidesBackButton = true
        navigationItem.title = "Heroes"
    }
    fileprivate func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell{
        //creo un "DispatchGrpup" para usarlo para hacer que el retorno de la celda espere a que finalicen las tareas asincrónicas
        let group = DispatchGroup()
        group.enter()
        //instanciamos la celda peronalizada que registramos más arriba en la tabla y lo casteamos al tipo de dicha celda para poder luego asignarles valor a sus atributos
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.titleOfCell.text = heroesList[indexPath.row].name
        cell.descriptionOfCell.text = heroesList[indexPath.row].description
        let task = URLSession.shared.dataTask(with: heroesList[indexPath.row].photo) { (data, response, error) in
            defer{
                group.leave()
            }
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
        group.wait()
        return cell
    }
    fileprivate func height() -> CGFloat{
        return 125.0
    }
    fileprivate func showHeroDetailTable(id:String,name:String,description:String,photo:URL){
        DispatchQueue.main.async {
            self.navigationController?.showHeroDetailTable(
                id: id,
                name: name,
                description: description,
                photo: photo
            )
        }
    }
}
