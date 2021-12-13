//
//  FriendListTest.swift
//  FriendListDemoTests
//
//  Created by Subhra Roy on 13/12/21.
//

/**
 - Load Friends from API on viewWillAppear
 - If success show list
 - If fails:
    - Retry twice:
        - If all retries fails - show error
        - If a retry success - show friend list
    - On selection show friend deatils
 */

import XCTest
@testable import FriendListDemo

class FriendListTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFriendListVC_with_viewDidLoad(){
        let service: ServiceManagerStub = ServiceManagerStub()
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.friendsCount(), 0)
    }
    
    func testFriendListAPI_with_viewWillAppear(){
        let friends = [Friend(
                        id: 100,
                        name: "John",
                        username: "",
                        email: "john@yopmail.com",
                        phone: "8902178012",
                        website: ""
                      )
        ]
        let service: ServiceManagerStub = ServiceManagerStub(friends: friends)
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.simulateViewWillAppear()
        XCTAssertEqual(sut.friendsCount(), 1)
    }
    
    func testLoadFriendListAPI(){
        let friends = [Friend(
            id: 100,
            name: "John",
            username: "",
            email: "john@yopmail.com",
            phone: "8902178012",
            website: ""
            ),
            Friend(
                id: 101,
                name: "Cris",
                username: "",
                email: "cris@yopmail.com",
                phone: "8902178011",
                website: ""
            ),
            Friend(
                id: 102,
                name: "Street",
                username: "",
                email: "street@yopmail.com",
                phone: "8902178013",
                website: ""
            )
        ]
        let service: ServiceManagerStub = ServiceManagerStub(friends: friends)
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.simulateViewWillAppear()
        XCTAssertEqual(sut.friendList.count, 3)
    }
    
    func testLoadFriendListAPI_FailThreeTimes(){
        
        let errorResponse: [Swift.Result<[Friend], ServiceError<ErrorState>>] = [
            .failure(ServiceError.failure(.nodata)),
            .failure(ServiceError.failure(.unknown)),
            .failure(ServiceError.failure(.invalid))
        ]
        
        let service: ServiceManagerStub = ServiceManagerStub(result: errorResponse)
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.simulateViewWillAppear()
        XCTAssertEqual(sut.errorMessage, "invalid")
    }
    
    func testLoadFriendListAPI_FailTwoTimes_SuccessOn_Final_Retry(){
         
        let friends = [
                Friend(
                id: 100,
                name: "John",
                username: "",
                email: "john@yopmail.com",
                phone: "8902178012",
                website: ""
            ),
            Friend(
                id: 101,
                name: "Cris",
                username: "",
                email: "cris@yopmail.com",
                phone: "8902178011",
                website: ""
            ),
            Friend(
                id: 102,
                name: "Street",
                username: "",
                email: "street@yopmail.com",
                phone: "8902178013",
                website: ""
            )
        ]
        
        let service: ServiceManagerStub = ServiceManagerStub(result: [
            .failure(ServiceError.failure(.nodata)),
            .failure(ServiceError.failure(.unknown)),
            .success(friends)
        ])
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.simulateViewWillAppear()
        XCTAssertEqual(sut.friendList.count, 3)
    }
    
    func testLoadFriendListAPI_FailFirstTime_SuccessOn_Second_Retry(){
        
        let friends = [
            Friend(
                id: 100,
                name: "John",
                username: "",
                email: "john@yopmail.com",
                phone: "8902178012",
                website: ""
            ),
            Friend(
                id: 101,
                name: "Cris",
                username: "",
                email: "cris@yopmail.com",
                phone: "8902178011",
                website: ""
            ),
            Friend(
                id: 102,
                name: "Street",
                username: "",
                email: "street@yopmail.com",
                phone: "8902178013",
                website: ""
            )
        ]
        
        let service: ServiceManagerStub = ServiceManagerStub(result: [
            .failure(ServiceError.failure(.invalid)),
            .success(friends)
        ])
        let sut: TestableFriendListViewController = TestableFriendListViewController()
        sut.viewModelSpy = FriendsViewModelStub(service: service)
        sut.simulateViewWillAppear()
        XCTAssertEqual(sut.friendList.count, 3)
    }


}

private class TestableFriendListViewController: ViewController{
    
    var viewModelSpy: FriendsViewModelStub!
    var friendList: [Friend]!
    var errorMessage: String!
        
    override func viewWillAppear(_ animated: Bool) {
        self.loadList()
    }
    
    func simulateViewWillAppear(){
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
    }
    
    func friendsCount()-> Int{
        //self.viewModelSpy.service.friendsCount
        //friendListTable.numberOfRows(inSection: 0)
        if let list = self.friendList , list.count > 0 {
           return list.count
        }else{
           return self.viewModelSpy.service.friendsCount
        }
    }
    
    private func loadList(for retryCount: Int = 0){
       
        viewModelSpy.load { [weak self] result in
            switch result{
                case .success(let list): self?.friendList = list
                case .failure(let error):
                    switch retryCount {
                        case let count where count == 2:
                            self?.show(error)
                        default:
                            self?.loadList(for: retryCount + 1)
                    }
            }
        }
    }
    
    func show(_ error: ServiceError<ErrorState>) -> Void{
        switch error {
            case .failure(let errorType):
                switch errorType {
                    case .invalid: errorMessage = "invalid"
                    case .nodata: errorMessage = "nodata"
                    case .unknown: errorMessage = "unknown"
                }
            case .success: break
        }
    }
}

private class ServiceManagerStub: ServiceProtocol{
    
    var friendsCount: Int = 0
    private var friends: [Swift.Result<[Friend], ServiceError<ErrorState>>]
    
    
    init(friends: [Friend] = []){
        self.friends = [.success(friends)]
    }
    
    init(result: [Swift.Result<[Friend], ServiceError<ErrorState>>]) {
        self.friends = result
    }
    
    func fetch(list: @escaping (Result<[Friend], ServiceError<ErrorState>>) -> ()){
        friendsCount = friendsCount + 1
        if friends.count > 0{
            list(friends.removeFirst())
        }else{
            list(.success([]))
        }
    }
}

private struct FriendsViewModelStub: ListProtocol{
    
    let service: ServiceManagerStub
    
    func load(list: @escaping (Result<[Friend], ServiceError<ErrorState>>) -> ()) {
        service.fetch { (result) in
            list(result)
        }
    }
        
}
