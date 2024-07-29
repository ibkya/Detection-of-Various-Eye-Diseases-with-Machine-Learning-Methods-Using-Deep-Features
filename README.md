<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF'den JSON'a İçerik-Soru-Cevap Çıkartma Aracı</title>
</head>
<body>

<h1>PDF'den JSON'a İçerik-Soru-Cevap Çıkartma Aracı</h1>

<p>Bu Python projesi, PDF belgelerini işleyerek anlamlı içerik-soru-cevap çiftleri çıkarır ve bunları yapılandırılmış JSON formatına dönüştürür. Projenin temel amacı, büyük dil modellerinin (LLM'ler) eğitimi için PDF'lerden çıkarılan ilgili verileri sağlamaktır.</p>

<h2>Özellikler</h2>
<ul>
    <li><strong>PDF'den Metin Dönüştürme:</strong> <code>pdfplumber</code> kullanarak PDF belgelerinden metin okur ve çıkarır.</li>
    <li><strong>Metin Temizleme:</strong> Çıkarılan metni gereksiz öğelerden, fazla boşluklardan ve ilgisiz bölümlerden arındırır.</li>
    <li><strong>Cümle Bölme:</strong> Temizlenmiş metni daha iyi işlenmesi için bireysel cümlelere böler.</li>
    <li><strong>İçerik Parçalama:</strong> Cümleleri yaklaşık 50 kelimelik anlamlı parçalara ayırır.</li>
    <li><strong>OpenAI GPT-3.5 Entegrasyonu:</strong> OpenAI'nin GPT-3.5 modelini kullanarak metin parçalarından içerik-soru-cevap çiftleri oluşturur.</li>
    <li><strong>JSON Çıktısı:</strong> Oluşturulan çiftleri kolay tüketim ve ileri işlem için yapılandırılmış bir JSON dosyasına biçimlendirir.</li>
</ul>

<h2>Gereksinimler</h2>
<ul>
    <li>Python 3.8+</li>
    <li>Gerekli Python paketleri:
        <ul>
            <li><code>pdfplumber</code></li>
            <li><code>openai</code></li>
        </ul>
    </li>
</ul>

<h2>Kurulum</h2>
<ol>
    <li>Depoyu klonlayın:
        <pre><code>git clone https://github.com/ibkya/Automatic-Data-Gainer-System
cd Automatic-Data-Gainer-System</code></pre>
    </li>
    <li>Gerekli paketleri yükleyin:
        <pre><code>pip install -r requirements.txt</code></pre>
    </li>
    <li>OpenAI API anahtarınızı ayarlayın:
        <pre><code>openai.api_key = 'your-openai-api-key'</code></pre>
    </li>
</ol>

<h2>Kullanım</h2>
<ol>
    <li>PDF dosyalarınızı bir dizine yerleştirin.</li>
    <li>Script'teki <code>pdf_path</code> değişkenini PDF dosyalarınızın yolunu içerecek şekilde değiştirin.</li>
    <li>Script'i çalıştırın:
        <pre><code>python app.py</code></pre>
    </li>
    <li>İşlenen veriler <code>chunks.json</code> dosyasına kaydedilecektir.</li>
</ol>

<h2>Kod Açıklaması</h2>
<ul>
    <li><code>extract_text_from_pdf_page_by_page</code>: PDF dosyasından sayfa bazında metin okur ve çıkarır.</li>
    <li><code>clean_text</code>: Çıkarılan metni gereksiz öğelerden arındırır.</li>
    <li><code>get_propositions</code>: Temizlenmiş metni bireysel önerilere böler ve işler.</li>
    <li><code>add_propositions</code>: Önerileri anlamlı parçalara ayırır ve parçaları yönetir.</li>
    <li><code>save_chunks_to_json</code>: İşlenmiş verileri JSON dosyasına kaydeder.</li>
</ul>

<h2>Örnek Çıktı</h2>
<p>Çıktı JSON dosyası aşağıdaki yapıya sahip olacaktır:</p>
<pre><code>{
    "soru_cevap": [
        {
            "context": "Kooperatiflerin kurumlar vergisi muafiyetinden yararlanabilmeleri için ana sözleşmelerinde; Sermaye üzerinden kazanç dağıtılmamasına, Yönetim kurulu başkan ve üyelerine kazanç üzerinden pay verilmemesine, Yedek akçelerinin ortaklara dağıtılmamasına, Sadece ortaklarla iş görülmesine dair hükümlerin bulunması ve bu kayıt ve şartlara da fiilen uyulması gerekmektedir.",
            "question": "Kooperatiflerin kurumlar vergisi muafiyetinden yararlanabilmesi için ana sözleşmelerinde hangi hükümlerin bulunması gerekmektedir?",
            "answer": "Sermaye üzerinden kazanç dağıtılmaması, yönetim kurulu başkan ve üyelerine kazanç üzerinden pay verilmemesi, yedek akçelerin ortaklara dağıtılmaması ve sadece ortaklarla iş görülmesine dair hükümlerin bulunması gerekmektedir. (Madde 4, Fıkra 1, Bent k)"
        },
        {
            "context": "20/5/2006 tarih ve 26173 sayılı Resmi Gazete’de yayımlanarak aynı tarihte yürürlüğe giren 5502 sayılı Sosyal Güvenlik Kurumu Kanununun geçici 1 inci maddesine göre, T.C. Emekli Sandığı, Bağ-Kur ve Sosyal Sigortalar Kurumu, Kanunun yürürlük tarihi itibarıyla Sosyal Güvenlik Kurumuna devredildiğinden, anılan Kanuna göre kurulan Sosyal Güvenlik Kurumu da kurumlar vergisinden muaf olacaktır.",
            "question": "5502 sayılı Sosyal Güvenlik Kurumu Kanunu'na göre hangi kurumlar kurumlar vergisinden muaftır?",
            "answer": "T.C. Emekli Sandığı, Bağ-Kur ve Sosyal Sigortalar Kurumu, 5502 sayılı Sosyal Güvenlik Kurumu Kanunu'nun yürürlük tarihi itibarıyla Sosyal Güvenlik Kurumuna devredildiğinden, Sosyal Güvenlik Kurumu kurumlar vergisinden muaf olacaktır. (Madde 4, Fıkra 1, Bent e)"
        }
    ]
}
</code></pre>

</body>
</html>
