import UIKit

//MARK: -PROTOCOLS-

private protocol TransformationDetailTableMethodsProtocol{
    func registerCell()
    func configurations()
    func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell
    func height() -> CGFloat
}

//MARK: -CLASS-

final class TransformationDetailTable: UITableViewController {
    private let id: String
    private let name: String
    private let heroDescription: String
    private let photo: URL
    init(id: String,name:String,description:String,photo:URL)
    {
        self.id = id
        self.name = name
        self.heroDescription = description
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -EXTENSIONS-

extension TransformationDetailTable{
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
        height()
    }
}

extension TransformationDetailTable:TransformationDetailTableMethodsProtocol{
    fileprivate func registerCell(){
        let nib = UINib(nibName: "DetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DetailCell")
    }
    fileprivate func configurations(){
        navigationItem.title = self.name
    }
    fileprivate func prepareAndReturnCell(indexPath: IndexPath) -> UITableViewCell{
        let group=DispatchGroup()
        group.enter()
        //instanciamos la celda peronalizada que registramos más arriba en la tabla y lo casteamos al tipo de dicha celda para poder luego asignarles valor a sus atributos
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        cell.titleOfCell.text = name
        cell.descriptionOfCell.text = heroDescription
        let task = URLSession.shared.dataTask(with: photo) { (data, response, error) in
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
        cell.transformationsButton.isHidden = true
        cell.transformationsButton.isEnabled = false
        return cell
    }
    fileprivate func height() -> CGFloat{
        return 725.0
    }
}
