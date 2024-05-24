import Map "mo:base/HashMap"; // İmports
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor SocialMedia {
  // SocialMedia adında bir aktör oluşturuluyor

  // Gönderi veri yapısı
  type Post = {
    author : Text; // Gönderinin yazarı (metin veri tipi)
    content : Text; // Gönderi içeriği (metin veri tipi)
    timestamp : Time.Time; // Gönderinin oluşturulma zamanı (zaman veri tipi)
  };

  // Hash fonksiyonu
  func natHash(n : Nat) : Hash.Hash {
    // Nat veri tipini Hash veri tipine dönüştüren fonksiyon
    Text.hash(Nat.toText(n)); // Nat veriyi Text veri tipine dönüştürüp hash değerini hesaplıyor
  };

  // Gönderilerin depolanacağı değişkenler
  var posts = Map.HashMap<Nat, Post>(0, Nat.equal, natHash); // Gönderilerin ID'leri ile eşleştirildiği HashMap
  var nextId : Nat = 0; // Bir sonraki gönderi ID'sini tutan değişken

  // Tüm gönderileri getirme işlemi
  public query func getPosts() : async [(Nat, Post)] {
    // Tüm gönderileri döndüren query fonksiyonu
    Iter.toArray(posts.entries()); // HashMap içindeki tüm gönderileri diziye dönüştürüyor
  };

  // Yeni gönderi ekleme işlemi
  public func addPost(author : Text, content : Text) : async Text {
    // Yeni gönderi ekleyen fonksiyon
    let id = nextId; // Yeni gönderi ID'si oluşturuluyor
    posts.put(id, { author = author; content = content; timestamp = Time.now() }); // Gönderi HashMap'e ekleniyor
    nextId += 1; // Bir sonraki gönderi ID'si artırılıyor
    "Gönderi başarıyla eklendi. Gönderi ID'si: " # Nat.toText(id); // Sonuç metni döndürülüyor
  };

  // Gönderiyi düzenleme işlemi
  public func editPost(author : Text, id : Nat, newContent : Text) : async Bool {
    // Gönderiyi düzenleyen fonksiyon
    switch (posts.get(id)) {
      // Gönderi ID'si ile gönderiye erişiliyor
      case (?post) {
        // Gönderi varsa
        if (post.author == author) {
          // Yazar doğruysa
          posts.put(id, { author = author; content = newContent; timestamp = post.timestamp }); // Gönderi düzenleniyor
          return true; // Başarılı olduğu belirtiliyor
        } else {
          return false; // Yetkilendirme hatası
        };
      };
      case null {
        // Gönderi ID'si geçersizse
        return false; // Geçersiz gönderi ID'si hatası
      };
    };
  };

  // Belirli bir gönderiyi görüntüleme işlemi
  public query func viewPost(id : Nat) : async ?Post {
    // Belirli bir gönderiyi döndüren query fonksiyonu
    posts.get(id); // Gönderiyi ID'si ile getiriyor
  };

  // Tüm gönderileri formatlı şekilde gösterme işlemi
  public query func showPosts() : async Text {
    // Tüm gönderileri döndüren query fonksiyonu
    var output : Text = "\n_____POSTS____"; // Başlık metni
    for ((id, post) : (Nat, Post) in posts.entries()) {
      // Tüm gönderileri döngüyle geziyor
      output #= "\nID: " # Nat.toText(id) # " | " # post.author # ": " # post.content; // Gönderi bilgilerini ekliyor
    };
    output # "\n"; // Sonuç metnini oluşturuyor
  };

  // Tüm gönderileri temizleme işlemi
  public func clearPosts() : async () {
    // Tüm gönderileri temizleyen fonksiyon
    for (key : Nat in posts.keys()) {
      // HashMap içindeki tüm anahtarları alıyor
      ignore posts.remove(key); // Gönderileri temizliyor
    };
  };
};
