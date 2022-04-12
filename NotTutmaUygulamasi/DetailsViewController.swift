//
//  DetailsViewController.swift
//  NotTutmaUygulamasi
//
//  Created by Furkan Eruçar on 2.04.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var kaydetButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var isimTextField: UITextField!
    @IBOutlet var fiyatTextField: UITextField!
    @IBOutlet var bedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Şimdi biz "+"ya da tıklansa, kaydedilen ürünü de açsak aynı view'a gitmek istiyoruz. Fakat burda "+" ya tıkladığımızda yeni değerler girilebilecek bir view isterken, eğer olan ürüne tıklandıysa o ürünün bilgilerinin gösterildiği şeklinde göstermek istiyoruz view'u
        if secilenUrunIsmi != "" { // Yani table view'dan bir ürün seçtiyse.
            // Core Data'dan seçilen bilgilerini göster.
            
            kaydetButton.isHidden = true
            
            if let uuidString = secilenUrunUUID?.uuidString {
                let appDelegateClass = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegateClass.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString) // Filtre ekliyoruz. format: yani neyi filtreliyim, args: neye göre filtreliyim.
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                isimTextField.text = isim
                            }
                            
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                fiyatTextField.text = String(fiyat)
                            }
                            
                            if let beden = sonuc.value(forKey: "beden") as? String {
                                bedenTextField.text = beden
                            }
                            
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("hata var")
                    
                }
                
            }
            
        } else { // Yani kullanıcı yukarıdaki "+" butonuna tıklayarak geldi
            
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            isimTextField.text = ""
            fiyatTextField.text = ""
            bedenTextField.text = ""
        }
        
        
        // Aşağıdaki kodları yazmadan uygulamayı çalıştırırsak eğer, klavye ekranın çoğunu kaplayacak ve ekran boyutuna bağlı olarak kullanıcının input girmesi gereken yerleri veya "kaydet" buttonunu kapatabilir. Bu yüzden ekranda boş bir yere tıklayınca klavyenin kapanmasını istiyoruz. Bunu sağlamak için iki tane şey yapmamız gerekiyor.
        // Birincisi herhangi bir yere tıklanıldığını algılamamız gerekiyor. (Tabi ki burada Gesture Recognizer kullanıcaz!)
        // İkincisi algıladığımızda klavyeyi nasıl kapatacağımızı bilmemiz gerekiyor.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat)) // Burada ekrana dokunulduğunda selector içindeki fonksiyonu uygulayacak. ViewController içinde gene bir selector fonksiyonu yapmıştık ve ona tıklandığında segue yapıyordu. Ama temel bir fark var, onun kodu button tıklanma koduydu, burası ise ekrana dokunma kodu. Burada ise tıklandığında klavyeyi kapatacak.
        view.addGestureRecognizer(gestureRecognizer) // !!!!Burada view ile bütün ekran için atıyoruz. view burada Storyboarddaki DetailsViewController view controlu içindeki View !!!!! eğer sadece içindeki resime tıklanmasını isteseydik o zaman imageView yazıcaktık başına!!!!!!!!! Textfielde atasaydık seçilen textField'ı yazıcaktık başına view yerine!!!!!!! Yani bu şu demek; View'a addGestureRecognizer özelliğini eklemek istiyorum böylece View içindeki bir yere tıklandığını algılayabilirim. Tıklanınca da gestureRecognizer fonksiyonunu yapıcak.
        
        // Şimdi de fotoğrafa tıklayınca ne olacağını yapıcaz.
        imageView.isUserInteractionEnabled = true // Kullanıcının etkileşime girebileceği bir hale getiriyoruz image'ı.
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec)) // Bunlar yukardakilerle aynı amaca hizmet edecek.
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        
    }
    
    
    @objc func gorselSec() { // Artık kullanıcı imageView'a tıkladığında aşağıda yazacaklarımız olacak.
        
        // Kullanıcı imageView'a tıkladığında galeriye gitsin istiyoruz.
        let picker = UIImagePickerController() // picker'ı oluşturduk fakat özelliklerini yazmamız gerekiyor. Kullanıcı nereye gidecek, nasıl gidecek, bir görsel seçerse nasıl geri getiricez, burada kullanıcaz bilmem ne.
        picker.delegate = self // Bunu yapmamızdaki amaç burdaki fonksiyonlarına ulaşabilmemiz. Daha önce yapmıştık. Yukarıya delegateleri yazmayı unutmuyoruz.
        picker.sourceType = .photoLibrary // Kaynağını belirtmemiz gerekiyor. Burada noktadan sonra olacak şeyi seçiyoruz, biz galeriyi seçtik
        picker.allowsEditing = true // Bu da mesela kullanıcı resmi seçtikten sonra zoomlamasını, crop etmesine izin verecek miyiz
        present(picker, animated: true, completion: nil) // present burda neyi göstereyim abime demek.
        // Buraya kadar kullanıcıyı kütüphaneye taşıyacak. Fakat görseli seçtikten sonra ne yapacağız? görseli imageView'a mı atayacağız? kullanıcıya mesaj mı göstereceğiz? Hepsi geliyor.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // Yani medya seçmeyi bitirince ne olacağını göstericez. Bu kod kullanıcı seçim yaptıktan sonra gerçekleşicek. İçinde bir de sözlük var dikkat! Biz bi anahtar kelime vericez any type'ında o da bize bi değer verecek.
        
        imageView.image = info[.originalImage] as? UIImage // Öncelikle viewcontrollerdaki image'ı değiştirmek istiyorum kullanıcının seçtiğiyle. Fakat yukarda Any type'ında verdiği için bizim onu UIImage'a çevirmemiz gerekiyor. Bunun için casting yapacağız. as?, kullanıcı vazgeçer, bi şey olur, yanlış bir şey seçer, UIImage'a çevrilmez, uygulamayı çökertmek istemeyiz. Bir de fotoğraf seçtiğimizde bize edit seçeneği verecek ama burda originalImage seçtiğimiz için edit'leri yok sayıp alacak.
        
        kaydetButton.isEnabled = true
        self.dismiss(animated: true, completion: nil) // Bizim viewControllerımızdan sonra açılan yeni bi viewController vardı imagePickerController (burada pop-up olarak çıkıcak), onu kapatıyor bu "dismiss". Yani imagePickerController'ı kapat ve imageView'a geri dön. !!!!! completion: burda sonunda bi şey olsun mu demek.!!!!
        
        // Bir de kullanıcı ilk defa uygulamayı kullandığında fotoğraflara erişim için izin isteyebiliriz soldaki info yerinden ve neden izin istediğimizi açıklayabiliriz. Info'ya geldikten sonra "+"ya tıklayıp oradan Privacy - Media Library Usage Description'u seçicez. Value da bilgi verebiliriz neden izin istediğimizle ilgili.
        
    }
    
    
    @objc func klavyeyiKapat() {
        view.endEditing(true) // Yani ekrana tıkladığımızda klavye kapanacak.
        
    }
    
    
    
    @IBAction func kaydetButtonClicked(_ sender: Any) {
        
        
        let appDelegateClassi = UIApplication.shared.delegate as! AppDelegate // UIApplication uygulamanın kendisini veriyor. AppDelegate class'ını burda kullanabilmek için yazılan kod.
        let context = appDelegateClassi.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context) // Alışveriş nesnemizi oluşturalım. NSEntityDescripton: core data içerisindeki entity'lere ulaşmamızı sağlayacak. forEntityName: "Alisveris" ise coredata içindeki entities kısmında hangisini kullanacaksak.
        alisveris.setValue(isimTextField.text!, forKey: "isim") // Yani bir anahtar kelime için bir değer tanımla. Burada anahtar kelime core Data içindeki entity'lerin içindeki attributelardır. Sonra bu anahtar kelimemizi hangi değere atayacağız? Burada isim içi kullanacağımız text'imiz için kullanacağız.
        alisveris.setValue(bedenTextField.text!, forKey: "beden") // Burda da diğer attrubite'u koyduk.
        
        if let fiyat = Int(fiyatTextField.text!) { // Burda da aynısını yapmamız gerekiyordu fiyat için fakat bize buradan bir Int değer gelicek ve bu int değeri String'e çevirmemiz gerekiyor. Çeviremezse diye if let kullanıyoruz. Böylece uygulama çökmeyecek. Eğer fiyatı int'e çevirebiliyorsa aşağıdaki kod çalışacak.
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
        alisveris.setValue(UUID(), forKey: "id") // Burda id Type'ı UUID olduğu için böyle yazdık. attribute'lar hangi type'daysa ona göre yazıyoruz.
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) // Görsel için imageView kullanırsak bize bi UIImage vericek. Bu UIImage'ı veriye çevirmemiz gerek. Burada jpegData bize veriye çevirecek. compressionQuality: ise sıkıştırma kalitesi. Veri tabanımıza çok büyük görseller kaydetmek iyi olmayabilir.
        alisveris.setValue(data, forKey: "gorsel")
        
        // Buraya kadar bütün verileri kaydettik. En son olarak yapacağımız şey de gerçekten bunu save etmek ki kullanıcı uygulamayı kapatıp açınca değiştirdiği veriler aynı kalsın. Bunun için appdelegate'deki context.save'i çağırıcaz. Fakat save() burda catch error yapısında olduğu için bunu do, try ile yapmamız lazım yoksa hata alırız.
        
        do {
            try context.save()
            print("kayıt edildi")
        } catch {
            print("hata var")
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)// Ama dönmeden önce diğer viewcontrollerlara yeni veri kaydettik diye haber vermek istiyoruz. Diğer tarafta bu haberi gözlemleyip bu yeni verileri çekmek için bir işlem yaptıralım. NSNotification.Name: Burda bir isim soruyor, ne mesajı yollayacaksın, yollamak istediğin bilgi ne diyor.
        self.navigationController?.popViewController(animated: true) // Yani son oluşturduğunuz viewcontroller'ı stack'den (yani navigasyonun olduğu yerden) atıyor ve bir öncekine geçiyor.
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

