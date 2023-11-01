import Foundation

struct DragonBallZNetworkModelToken{
    //DragonBallZNetworkModelToken
    static var token:String? = nil
}

final class DragonBallZNetworkModel{
    
    //el session que se usara en todo el DragonBallZNetworkModel, en las task de las funciones
    //cuando se instancie la clase DragonBallZNetworkModel session tendrá el valor por defecto ".shared", pero cuando instanciemos la clase en el archivo de test le pasaremos por parametro la session que se usara para el test
    private var session: URLSession
    init (session: URLSession = .shared) {
        self.session = session
    }
    
    //armamos los errores posibles a aparecer
    enum NetworkError:Error,Equatable {
        case unknown
        case malformedUrl
        case decodingFailed
        case encodingFailed
        case noData
        case statusCode(code:Int?)
        case noToken
    }
    
    //"/api/auth/login/"
    //login (debe ser correcto el nombre y la password)
    func login (email: String, password: String, completion: @escaping (NetworkError?)-> Void ){
        
        //1)armamos los componentes de la url y mediante ella creamos la url que se le va a pasar al request
        var URLComponents = URLComponents()
        URLComponents.scheme = "https"
        URLComponents.host = "dragonball.keepcoding.education"
        URLComponents.path = "/api/auth/login"
        guard let url = URLComponents.url else {
            completion(NetworkError.malformedUrl)
            return
        }
        
        //2)armamos la request pasandole la url que creamos
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let loginstring = String(format: "%@:%@",email,password)
        guard let logindata = loginstring.data(using: .utf8) else {
            completion(NetworkError.encodingFailed)
            return
        }
        let base64loginstring = logindata.base64EncodedString()
        request.setValue("Basic \(base64loginstring)", forHTTPHeaderField: "Authorization")
        
        //3)comenzamos el llamado a la request
        let task = session.dataTask(with: request) { data, response, error in
            
            //verificamos que no hay habido ningún error en la llamada
            guard error == nil else {
                completion(NetworkError.unknown)
                return
            }
            
            //nos aseguramos que la llamada haya sido exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(NetworkError.statusCode(code: (response as? HTTPURLResponse)?.statusCode))
                return
            }
            
            //verificamos que haya data
            guard let data else {
                completion(NetworkError.noData)
                return
            }
            
            //nos aseguramenos que el dato que vino se decodifique correctamente y lo guardamos en una variable token
            guard let token = String(data: data, encoding: .utf8) else {
                completion(NetworkError.decodingFailed)
                return
            }
            
            DragonBallZNetworkModelToken.token = token
            completion(nil)
        }
        task.resume()
    }

    //"/api/heros/all"
    //devolvemos la lista de heroes
    func getHeroesList (completion: @escaping ([Hero],NetworkError?) -> Void ){
        
        //1)armamos los componentes de la url y mediante ella creamos la url que se le va a pasar al request
        var URLComponents = URLComponents()
        URLComponents.scheme = "https"
        URLComponents.host = "dragonball.keepcoding.education"
        URLComponents.path = "/api/heros/all"
        guard let url = URLComponents.url else {
            completion([],NetworkError.malformedUrl)
            return
        }
        URLComponents.queryItems = [URLQueryItem(name: "name", value: "")]
        
        
        //2)armamos la request pasandole la url que creamos
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = URLComponents.query?.data(using: .utf8)
        request.setValue("Bearer \(DragonBallZNetworkModelToken.token!)", forHTTPHeaderField: "Authorization")
        
        //3)comenzamos el llamado a la request
        let task = session.dataTask(with: request) { data, response, error in
            
            //verificamos que no hay habido ningún error en la llamada
            guard error==nil else {
                completion([],NetworkError.unknown)
                return
            }
            
            //nos aseguramos que la llamada haya sido exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion([],NetworkError.statusCode(code: (response as? HTTPURLResponse)?.statusCode))
                return
            }
            
            //verificamos que haya data
            guard let data else {
                completion([],NetworkError.noData)
                return
            }
            
            //se intenta decodificar "[Hero]"
            guard let heroes = try? JSONDecoder().decode([Hero].self, from: data) else {
                completion([],NetworkError.decodingFailed)
                return
            }
            
            completion(heroes,nil)
        }
        task.resume()
    }
    
    //"/api/heros/tranformations"
    //devolvemos la lista de transformaciones del heroe
    func getHeroeTransformations (heroId: String,completion: @escaping ([HeroTransformation],NetworkError?) -> Void ){
        
        //1)armamos los componentes de la url y mediante ella creamos la url que se le va a pasar al request
        var URLComponents = URLComponents()
        URLComponents.scheme = "https"
        URLComponents.host = "dragonball.keepcoding.education"
        URLComponents.path = "/api/heros/tranformations"
        guard let url = URLComponents.url else {
            completion([],NetworkError.malformedUrl)
            return
        }
        URLComponents.queryItems = [URLQueryItem(name: "id", value: heroId)]
        
        //2)armamos la request pasandole la url que creamos
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = URLComponents.query?.data(using: .utf8)
        request.setValue("Bearer \(DragonBallZNetworkModelToken.token!)", forHTTPHeaderField: "Authorization")

        //3)comenzamos el llamado a la request
        let task = session.dataTask(with: request) { data, response, error in
            
            //verificamos que no hay habido ningún error en la llamada
            guard error==nil else {
                completion([],NetworkError.unknown)
                return
            }
            
            //nos aseguramos que la llamada haya sido exitosa
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion([],NetworkError.statusCode(code: (response as? HTTPURLResponse)?.statusCode))
                return
            }
            
            //verificamos que haya data
            guard let data else {
                completion([],NetworkError.noData)
                return
            }
            
            //se intenta decodificar "[HeroTransformation]"
            guard let heroTransformations = try? JSONDecoder().decode([HeroTransformation].self, from: data) else {
                completion([],NetworkError.decodingFailed)
                return
            }
            
            completion(heroTransformations,nil)
        }
        task.resume()
    }
}
