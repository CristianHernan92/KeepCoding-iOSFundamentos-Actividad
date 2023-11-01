/*
 Resumen:
 -la clase dentro del archivo de test en donde crearemos los métodos de test hereda de "XCTestCase"
 -los métodos de test deben empezar con la palabra "test"
 -usaremos los "XCT..." para verificar que se cumpla tal condición dentro de los métodos de test, por ejemplo el "XCTAssertEqual" que sirve para verificar que un dato sea igual a tal valor, sino fallá el test
*/

import XCTest
//importar nuetra carpeta que contiene los controladores,vistas,modelos,etc. de nuestro proyecto, anteponiendole @testable para poder acceder a clases, etc. que sean "internal" de nuestro proyecto importado
@testable import DragonBallZ

//uasaremos esta clase para manejar los request sin utilizar apis reales y aparentar que datos que deberían funcionar o no en los endpoints
//MARK: CLASE PARA LA CONFIGURACIÓN DE LA SESSION QUE UTILIZAREMOS PARA LOS TEST
final class DragonBallZNetworkModelTestURLProtocol : URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    static var error: DragonBallZNetworkModel.NetworkError?
    //manejador de requests que devuelve una tupla que contendrá el response y la data
    //es estático, se tiene que implementar en los métodos de test
    static var requestHandler : ((URLRequest) throws -> (Data,HTTPURLResponse))?

    override func startLoading() {
        //verificamos que se haya implementado el requestHandler en el método de test
        guard let handler = DragonBallZNetworkModelTestURLProtocol.requestHandler else {
            assertionFailure("No handler implemented")
            return
        }
        
        do{
            let (data,response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        catch{
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

//MARK: EJECUCIÓN
final class DragonBallZNetworkModelTest: XCTestCase{
    private var sut: DragonBallZNetworkModel!
    
    //se ejecuta antes de cada metodo del test
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [DragonBallZNetworkModelTestURLProtocol.self]
        let session = URLSession(configuration: configuration)
        //sobrescribiremos la session de DragonBallZNetworkModel por la que le pondremos, con la que manejaremos nosotros los velores de data,response y error que se le envian a cada api DragonBallZNetworkModelTestURLProtocol junto con sus métodos
        sut = DragonBallZNetworkModel(session: session)
    }
    //se ejecuta después de cada metodo del test
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    //MARK: METODOS DEL TEST (todos los métodos de test deben empezar con la palabra test)
    
    //test modelo login
    func testLogin(){
        let expectedToken = "abcdefg1234567"
        let email = "email@email.com"
        let password = "qwer12345Z"
        
        //imlpementamos el requestHandler puesto en la session suplantadora que creamos
        DragonBallZNetworkModelTestURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url!.scheme, "https")
            
            let loginString = String(format: "%@:%@", email, password)
            let loginData = loginString.data(using: .utf8)!
            let base64LoginData = loginData.base64EncodedString()
            
            //tiene que cumplirse que el request value sea igual a Basic con bese64LoginData, es decir le haya configurado así antes de empezar la llamada
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Basic \(base64LoginData)")
            
            //tiene que cumplirse que la data que se devolvera cumpla que se pueda convertir a data usando utf8 , y el response cumpla también con lo puesto
            let data = try XCTUnwrap(expectedToken.data(using:.utf8))
            let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://dragonball.keepcoding.education")!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"]))
            
            return (data,response)
        }
        
        //creamos una expectación (necesario para lo asincrónico)
        let expectation = expectation(description: "Waithing the sut.login")
        
        sut.login(email: email, password: password) { error in
            guard error == nil else {
                //si la función de login retornó error entonces hacemos fallar el test con XCFail
                XCTFail("The login function return with the error: \(error!)")
                return
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    //test modelo getHeroesList
    func testGetHeroesList(){
        DragonBallZNetworkModelToken.token = "abcdefg1234567"
        let heroeArray:[Hero] = [
            Hero(id: "1", name: "Goku", description: "Description1", photo: URL(string: "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")!, favorite: false),
            Hero(id: "2", name: "Vegeta", description: "Description2", photo: URL(string: "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/vegetita.jpg?width=300")!, favorite: false)
        ]
        
        DragonBallZNetworkModelTestURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url!.scheme, "https")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(DragonBallZNetworkModelToken.token!)")
            
            let data = try XCTUnwrap(JSONEncoder().encode(heroeArray))
            let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://dragonball.keepcoding.education")!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"]))
            
            return (data,response)
        }
        
        
        let expectation = expectation(description: "Waithing the sut.getHeroesList")
        sut.getHeroesList { data, error in
            guard error == nil else {
                //si la función de login retornó error entonces hacemos fallar el test con XCFail
                XCTFail("The login function return with the error: \(error!)")
                return
            }
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    //test modelo getHeroeTransformations
    func testGetHeroeTransformations(){
        DragonBallZNetworkModelToken.token = "abcdefg1234567"
        let heroID = "1"
        let heroeTransformationsArray:[HeroTransformation] = [
            HeroTransformation(id: "1", name: "Transformation1", description: "Description1", photo: URL(string: "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")!, hero: HeroID(id: heroID)),
            HeroTransformation(id: "2", name: "Transformation2", description: "Description2", photo: URL(string: "https://areajugones.sport.es/wp-content/uploads/2017/05/Goku_Kaio-Ken_Coolers_Revenge.jpg")!, hero: HeroID(id: heroID))
        ]
        
        DragonBallZNetworkModelTestURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url!.scheme, "https")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(DragonBallZNetworkModelToken.token!)")
            
            let data = try XCTUnwrap(JSONEncoder().encode(heroeTransformationsArray))
            let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://dragonball.keepcoding.education")!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"]))
            
            return (data,response)
        }
        
        
        let expectation = expectation(description: "Waithing the sut.getHeroeTransformations")
        sut.getHeroeTransformations(heroId: heroID) { data, error in
            guard error == nil else {
                //si la función de login retornó error entonces hacemos fallar el test con XCFail
                XCTFail("The login function return with the error: \(error!)")
                return
            }
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
}

