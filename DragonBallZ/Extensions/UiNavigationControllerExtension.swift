import UIKit

extension UINavigationController{
    func showHeroTable(with data: [Hero]){
        DispatchQueue.main.async {
            self.pushViewController(
                HeroesTable(heroesList: data),
                animated: true)
        }
    }
    func showHeroDetailTable(id:String,name:String,description:String,photo:URL){
        DispatchQueue.main.async {
            self.pushViewController(
                HeroDetailTable(id:id,name:name,description:description,photo:photo),
                animated: true)
        }
    }
    func showTransformationTable(with data: [HeroTransformation]){
        DispatchQueue.main.async {
            self.pushViewController(
                TransformationsTable(heroesTransformationsList: data),
                animated: true)
        }
    }
    func showTransformationDetailTable(id:String,name:String,description:String,photo:URL){
        DispatchQueue.main.async {
            self.pushViewController(
                TransformationDetailTable(id:id,name:name,description:description,photo:photo),
                animated: true)
        }
    }
}
