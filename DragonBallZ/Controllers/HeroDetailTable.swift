import UIKit

//MARK: -PROTOCOLS-

private protocol HeroDetailTableMethodsProtocol{
    func registerCell()
    func configurations()
    func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell
    func height() -> CGFloat
}

//MARK: -CLASS-

final class HeroDetailTable: UITableViewController {
    private let id: String
    private let name: String
    private let heroDescription: String
    private let photo: URL
    //variable para usar en la función de "@objc fileprivate func transformationsButtonTapped" para almacenar la lista de transformaciones ya que no se le pude poner parámetro a la función
    private var transformationsList: [HeroTransformation]
    init(id:String,name:String,description:String,photo:URL)
    {
        self.id = id
        self.name = name
        self.heroDescription = description
        self.photo = photo
        self.transformationsList = []
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -EXTENSIONS-

extension HeroDetailTable{
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        configurations()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = prepareAndReturnCell(indexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height()
    }
}

extension HeroDetailTable:HeroDetailTableMethodsProtocol{
    fileprivate func registerCell(){
        let nib = UINib(nibName: "DetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DetailCell")
    }
    fileprivate func configurations(){
        navigationItem.title = self.name
    }
    fileprivate func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell{
        //creo un "DispatchGrpup" para usarlo para hacer que el retorno de la celda espere a que finalicen las tareas asincrónicas
        let group = DispatchGroup()
        //instanciamos la celda peronalizada que registramos más arriba en la tabla y lo casteamos al tipo de dicha celda para poder luego asignarles valor a sus atributos
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        cell.titleOfCell.text = self.name
        cell.descriptionOfCell.text = self.heroDescription
        let task = URLSession.shared.dataTask(with: self.photo) { (data, response, error) in
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
        
        //indico al DispatchGroup que empieza una taréa a esperar
        group.enter()
        //traigo todas las transformaciones del heroe seleccionado
        DragonBallZNetworkModel.getTransformationsList(heroId: id) { [weak self] data in
            defer{
                //le digo que la tarea a esperar ya está finalizada
                group.leave()
            }
            DispatchQueue.main.async {
                if (data == []){
                    cell.transformationsButton.isHidden = true
                    cell.transformationsButton.isEnabled = false
                }else{
                    //agregamos la función para el evento "touchUpInside" del botón "transformationsButton" de la celda
                    self?.transformationsList = data
                    cell.transformationsButton.addTarget(
                        self,
                        action: #selector(self?.transformationsButtonTapped(_:)),
                        for: .touchUpInside
                    )
                }
            }
        }
        group.wait()
        return cell
    }
    fileprivate func height() -> CGFloat{
        return 725.0
    }
    @objc fileprivate func transformationsButtonTapped(_ sender: UIButton) {
        self.navigationController?.showTransformationTable(with: self.transformationsList)
    }
    
    

    
}
