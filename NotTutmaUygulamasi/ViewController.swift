//
//  ViewController.swift
//  NotTutmaUygulamasi
//
//  Created by Furkan Eruçar on 2.04.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenIsim = ""
    var secilenUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(eklemeButtonuTiklandi))
        //navigationController: navigation kısmına işlem yapabilmek için önce bunu yazıyoruz. "." koyduktan sonra bu controllerın özelliklerini göreceğiz. Burada "navigationBar" seçtik çünkü navigation controllerının en üstüne ulaşmak istiyoruz; Pil'in, şebekenin, Wi-fi'nın gözüktüğü yere. Oraya Topbar (üst bar) denir. Yine burada "topItem", ekranın üst kısmını işaret ediyor. "rightBarButtonItem" ise artık ekrandaki tam konumu gösteriyor. Kısaca ekranın sağ üst köşesini kullanmak için bunları yazıyoruz. Burada her nokta koyduğumuzda bi öncekinin özelliklerini kullanmış oluyoruz. Tümdengelim gibi.
        
        //UIBarButtonItem: ise seçtiğimiz konuma button eklememize yarıyor. Aynı şekilde "UIButton da kullanabilirdik ama bu kullandığımız daha işlevsel. Burada "barButtonSystemItem: UIBarButtonItem.SystemItem.add"da UIBarButtonItem.SystemItem yazdıktan sonra nokta koyarsak koyacağımız button'un simgesini gösteriyor. Biz ".add" yazdık çünkü yeni bir input eklemek istiyoruz bu yüzden .add bize "+" şeklinde bir button göstericek. Mesela ".camera" yazarsak kamera simgesi çıkıcak butonda.
        
        //Burada "targer: self" içinde bulunduğumuz viewController Class'ını işaret ediyor. "action:" ise içine koyacağımız selector'daki fonksiyonu yerine getirecek.
        
        // Eşitliğin sol tarafı navigation bar kısmını seçmemize yarıyor. Yani işlem yapacağımız konumu seçiyoruz. Eşitliğin sağ tarafında bu seçtiğimiz yere neler ekleyeceğimizi gösteriyor.
        // nokta dan sonra zincirleme isim tamlaması gibi idisinin idisinin idisi diye gidiyor son noktaya kadar, yani navigationController'ın navigationBar'ının topItem'inin rightBarButtonItem'ı
        // Başka bir deyişle furkan'ın evindeki odasının masasının üzerindeki laptop; furkan.home.livingroom.table.laptop
        
        verileriAl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // Görünüm gösterilmeden önce çağırılıyor.
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil) // Burada selector fonksiyonu, bu bildirim gelirse ne yapayım demek. Biz fonksiyonu daha önce yazmıştık zaten onu direk selector olarak kullanıcaz.
    }
    
    
    @objc func verileriAl() { // Verileri çekmek için bir fonksiyon yazalım. Bunu viewDidLoad' altında da yapabilirdik ama başka yerde kullanırsak diye fonksiyon olarak yazalım. Buraya gene appdelegate'i tanımlamamız lazım ve yine context'i kullanarak işlemlerimizi yapıcaz.
        
        isimDizisi.removeAll(keepingCapacity: false) // Yani bu dizi içerisindeki her şeyi sil. böylece dizimiz temiz başlayacak.
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegateClass = UIApplication.shared.delegate as! AppDelegate // Bunları detaisViewController classında yapmıştık.
        let context = appDelegateClass.persistentContainer.viewContext
        // Buraya kadar olan kısmı detaisViewController classında yapmıştık. Veri kaydetmeyi gördük, bir NSEntityDescription yardımıyla yapıyorduk. Fakat görmediğimiz bir şey var.
        // context.fetch(<#T##request: NSFetchRequest<NSFetchRequestResult>##NSFetchRequest<NSFetchRequestResult>#>): fetch burda verileri getirmek. Fakat burda fetch bizden bir NSFetchRequest istiyor. Yani bir veriyi çekme isteği yapmamız gerekiyor. Veri çekme isteğini oluşturunca context'e söyleyeğiz ve veriyi çekecek. Veri çekme isteğinde de bütün detayları belirteceğiz, entitiyname nedir, neyi çekiyoruz, hangi verileri çekeceğiz, işleyeceğiz onu belirtmemiz gerekiyor.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris") // NSFetchRequest(entityName: "Alisveris") olarak yazarsak bize bir hata verecek. Bu hatayı fix yaparsak yukardaki hale gelecek. Buradaki <NSFetchRequestResult>: nasıl tipte bir veriyle karşılaştığımız, bunun ne tipinde olduğunu belirtmemiz gerekiyor. Bu da bize bir fetch request result verecek yani sonuç. Şimdi bu sonucu nasıl alacağız nasıl işleyeceğiz bakalım. Ama öncelikle bu isteğimizi değişken olarak tanımlamamız gerekiyor üstte yaptığımız gibi.
        fetchRequest.returnsObjectsAsFaults = false // Çok büyük veriler çekerken caching mekanizmasından da faydalanabilmek için false yapılabilir. Bu örnek için gerek yok ama dursun.
        
        do { // fetch burda hata yakalama yapısında olduğu için do, try kullanıcaz.
            let sonuclar = try context.fetch(fetchRequest) // Burda farklı bir durum söz konusu. değişkene atadağımız için try yani dene dediğimiz yer neresi olacak? ='in sağ tarafı, bu yüzden try'ı oraya yazıyoruz. Burada fetch'in ne döndürdüğü önemli. fetch burada bize bir Any dizisi ([Any]) döndürecek. Herhangi bir obje olarak döndürüyor. Normalde NSManagedObject olarak döndürmesi lazım ama burada any var. Ayrıca sonuclar burda artık bir array oldu.
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject] { // Yukarda dediğimiz gibi, sonuclar burda any ama ben bunu NSManagedObject'e dönüştürmek istiyorum. Gene casting dermanımız. sonuclar array olduğu array cinsinde yazdık. Fakat bu diziyi ben tek tek almam lazım, o yüzden for loop yapıyoruz.
                    if let isim = sonuc.value(forKey: "isim") as? String { // Verileri coreData'dan çekicez. Bütün verileri viewcontroller içerisinde saklamanın anlamı yok. bütün görselleri tanımlamamıza gerek yok mesela. id'yi yollarız, ve id ile tekrar çekeriz verileri. id ve isim yapmak yeterli.
                        isimDizisi.append(isim)
                    }
                    
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    } // Buraya kadar her şey güzel, bunu şimdi bir tableview'a bağlamamız gerekiyor.
                    
                }
                // tableview'un bir özelliği olarak verileri bir yerde değiştiriyorsak mesela üstteki for loop bittikten sonra aşağıdakini yazmamız gerekiyor
                tableView.reloadData() // Abicim ben dataları değiştirdim hadi güncelle demek. Yeni bir veri olduğunu ve onu göstermesi gerektiğini tableView biliyor.
            }
           
            
        } catch {
            print("hata var")
        }
    }
    
    
    @objc func eklemeButtonuTiklandi() { // Yukarda oluşturduğumuz button'a tıkladığımızda ne olacağını burada yazıcaz.
        secilenIsim = ""
        performSegue(withIdentifier: "toDetailVc", sender: nil) // "performSegue"; Ekleme butonuna tıklayınca "withIdentifier:"'da yazan id'deki segueyi çalıştıracak ve hangi viewController'a bağlıysa onu göstericek.
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row] // isimDizisinin ilgili row'u neyse onu gösterteceğiz.
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVc" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenUrunIsmi = secilenIsim
            destinationVC.secilenUrunUUID = secilenUUID
            // Böylece verilerimizi aktarmış oluyoruz.
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsim = isimDizisi[indexPath.row] //isimdizisinden secilen isim dizisine aktarabilirim. seçildiği index'e alıyoruz.
        secilenUUID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailVc", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { // Burda silme işlemine göre işlem yapıcaz.
        if editingStyle == .delete {
            // İlgili veriyi silmeden önce veriyi veri tabanından getirmemiz gerekiyor.
            
            let appDelegateClass = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegateClass.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    
                    for sonuc in sonuclar as! [NSManagedObject] {
                        
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row] {
                                
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    
                                }
                                
                                break // for'dan itibaren ilgili veriyi getiriyoruz ve o seçtiğimiz veriyi siliyoruz. Burada break kullanmamızın amacı bir tanesini ele alsak bile tekrar çalıştırmasına gerek yok, olmayan bir şeyi silmeye çalışacak ve sistemi yoracak.
                            }
                        }
                    }
                }
            } catch {
                print("hata")
            }
        }
    }
    
   
    
    
    
}


//        struct Home {
//            var livingRoom: Room
//            var kitchen: Kitchen
//            var bathroom: Bathroom
//        }
//
//        struct Room {
//            var bed: Item/
//            var table : Item
//
//        }
//        mesela
//            var Home = Home(livingRoom: Room(table: Item())) // Home olusturdum bunun livngRoom diye parametresi var o da bi room ve icine itemlar aliyor mesela
//
//        Home.livingRoom.table diye ulasabilirim
//
//        Hatta soyle daha da guzel olur
//
//        struct Home {
//            var room: Room?
//        }
//
//        struct Room {
//            var name: String?
//
//            [Item]
//        }
//
//        let furkanHome = Home(room: Room(name: "living room", items: [])) // mesela tamam mi ben items eklemek istiyorum diyelim ki furkanHome'u da let degil var diye dusun
//
//        furkanHome.room.items = [Item1, Item2, Item3]
//
//
//    }

