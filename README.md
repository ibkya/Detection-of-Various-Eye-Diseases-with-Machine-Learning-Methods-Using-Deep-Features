<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
   
</head>
<body>

<h1>PDF'den JSON'a İçerik-Soru-Cevap Çıkartma Aracı</h1>

<p>Bu Python projesi, PDF belgelerini işleyerek anlamlı içerik-soru-cevap çiftleri çıkarır ve bunları yapılandırılmış JSON formatına dönüştürür. Projenin temel amacı, büyük dil modellerinin (LLM'ler) eğitimi için PDF'lerden çıkarılan ilgili verileri sağlamaktır.</p>

<h2>Özellikler</h2>
<ul>
    <li><strong>PDF'den Metin Dönüştürme:</strong> <code>pdfplumber</code> kullanarak PDF belgelerinden metin okur ve çıkarır.</li>
    <li><strong>Metin Temizleme:</strong> Çıkarılan metni gereksiz öğelerden, fazla boşluklardan ve ilgisiz bölümlerden arındırır.</li>
    <li><strong>Cümle Bölme:</strong> Temizlenmiş metni daha iyi işlenmesi için bireysel cümlelere böler.</li>
    <li><strong>İçerik Parçalama:</strong> Cümleleri anlamlı parçalara ayırır.</li>
    <li><strong>OpenAI GPT-3.5 Entegrasyonu:</strong> OpenAI'nin GPT-3.5 modelini kullanarak metin parçalarından içerik-soru-cevap çiftleri oluşturur.</li>
    <li><strong>JSON Çıktısı:</strong> Oluşturulan çiftleri kolay tüketim ve ileri işlem için yapılandırılmış bir JSON dosyasına biçimlendirir.</li>
</ul>

<h2>Gereksinimler</h2>
<ul>
    <li>Python 3.8+</li>
    <li>Gerekli Python paketleri:
        <ul>
            <li><code>pdfplumber</code></li>
            <li><code>rich</code></li>
            <li><code>langchain</code></li>
            <li><code>langchain-experimental</code></li>
            <li><code>langchain-openai</code></li>
            <li><code>langchain-core</code></li>
            <li><code>dotenv</code></li>
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
        <pre><code>echo "OPENAI_API_KEY=your-openai-api-key" > .env</code></pre>
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

<h3>app.py</h3>
<ul>
    <li><code>extract_text_from_pdf_page_by_page</code>: PDF dosyasından sayfa bazında metin okur ve çıkarır.
        <pre><code>def extract_text_from_pdf_page_by_page(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            yield page_num + 1, page.extract_text()
</code></pre>
    </li>
    <li><code>clean_text</code>: Çıkarılan metni gereksiz öğelerden arındırır.
        <pre><code>def clean_text(text):
    text = text.replace('\n', ' ').replace('\r', '')
    return ''.join(ch for ch in text if ord(ch) >= 32 or ch in 'çÇğĞıİöÖşŞüÜ')
</code></pre>
    </li>
    <li><code>get_propositions</code>: Temizlenmiş metni bireysel önerilere böler ve işler.
        <pre><code>def get_propositions(text):
    try:
        cleaned_text = clean_text(text)
        cleaned_text = f"Metin: {cleaned_text} \nLütfen bu metni analiz et ve Türkçe'de kal."
        runnable_output = runnable.invoke({"input": cleaned_text}).content
        propositions = extraction_chain.invoke(runnable_output)["text"][0].sentences
        return propositions
    except json.decoder.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        print(f"Problematic text: {runnable_output}")
        return []
</code></pre>
    </li>
    <li><code>main</code>: PDF dosyasını okur, metni temizler, parçalar ve anlamlı öneriler oluşturur.
        <pre><code>pdf_path = "/Users/ibrahim/Desktop/workspace/Agentic Chunker/dataset/EK 1) 5520 Sayılı Kurumlar Vergisi Kanunu.pdf"

obj = hub.pull("wfh/proposal-indexing")
llm = ChatOpenAI(model='gpt-3.5-turbo')
runnable = obj | llm

class Sentences(BaseModel):
    sentences: list[str]

extraction_chain = create_extraction_chain_pydantic(pydantic_schema=Sentences, llm=llm)

text_splitter = SemanticChunker(OpenAIEmbeddings(model="text-embedding-3-small"))

all_chunks = []
ac = AgenticChunker()

with open("context.txt", "w", encoding="utf-8") as context_file:
    for page_num, text in extract_text_from_pdf_page_by_page(pdf_path):
        print(f"Sayfa {page_num} işleniyor")
        context_file.write(f"Sayfa {page_num}\n{text}\n\n")

        if text.strip():
            documents = text_splitter.create_documents([text])
            paragraphs = text.split("\n\n")
            text_propositions = []
            for para in paragraphs:
                propositions = get_propositions(para)
                text_propositions.extend(propositions)

            ac.add_propositions(text_propositions)

with open("chunks.json", "w", encoding="utf-8") as f:
    json.dump(ac.get_chunks(get_type='dict'), f, ensure_ascii=False, indent=4)

print("Parçalar chunks.json dosyasına başarıyla kaydedildi")
</code></pre>
    </li>
</ul>

<h3>agentic_chunker.py</h3>
<ul>
    <li><code>AgenticChunker</code>: Önerileri anlamlı parçalara ayırmak ve gruplamak için kullanılır.
        <pre><code>class AgenticChunker:
    def __init__(self, openai_api_key=None):
        self.chunks = {}
        self.id_truncate_limit = 5
        self.llm = ChatOpenAI(model='gpt-3.5-turbo', openai_api_key=openai_api_key, temperature=0)
        self.generate_new_metadata_ind = True
        self.print_logging = True

        if openai_api_key is None:
            openai_api_key = os.getenv("OPENAI_API_KEY")

        if openai_api_key is None:
            raise ValueError("API key is not provided and not found in environment variables")
</code></pre>
    </li>
    <li><code>add_propositions</code>: Önerileri ekler.
        <pre><code>def add_propositions(self, propositions):
    for proposition in propositions:
        corrected_proposition = self.correct_proposition(proposition)
        if corrected_proposition:
            self.add_proposition(corrected_proposition)
        else:
            if self.print_logging:
                print(f"\nGeçersiz öneri atlandı: '{proposition}'")
</code></pre>
    </li>
    <li><code>correct_proposition</code>: Öneriyi düzeltir.
        <pre><code>def correct_proposition(self, proposition):
    PROMPT = ChatPromptTemplate.from_messages(
        [
            ("system", "Bu model sadece Türkçe konuşmalıdır. Size verilen her bir öneriyi lütfen Türkçe olarak işleyin ve yanıtlayın."),
            (
                "system",
                """
                Size verilen her bir öneriyi gözden geçirin ve 'Bu yasa', 'Bu yönetmelik' gibi genel ifadeleri genellenen yasa veya yönetmeliğin adıyla değiştirin. Eğer öneri

 zaten belirli bir yasa adı içeriyorsa, onu olduğu gibi bırakın.
                Düzeltilmemiş Örnek: 'Bu yönetmelik bankaların risk gruplarını saptamalarını ve kredi sınırlarını hesaplamalarını kapsar.
                Düzeltilmiş Örnek: 'Kredi Değerlendirme ve Risk Değerlendirme Yönetmeliği, bankaların risk gruplarını saptamalarını ve kredi sınırlarını hesaplamalarını kapsar.'
                
                Sadece düzeltilmiş öneriyi yanıt olarak verin.
                """,
            ),
            ("user", "{proposition}"),
        ]
    )

    runnable = PROMPT | self.llm

    corrected_proposition = self._invoke_with_retry(runnable, {
        "proposition": proposition
    })

    return corrected_proposition.strip() if corrected_proposition else None
</code></pre>
    </li>
    <li><code>add_proposition</code>: Düzeltlenmiş öneriyi ekler.
        <pre><code>def add_proposition(self, proposition):
    if self.print_logging:
        print(f"\nEkleniyor: '{proposition}'")

    if len(self.chunks) == 0:
        if self.print_logging:
            print("Parça yok, yeni bir tane oluşturuluyor")
        self._create_new_chunk(proposition)
        return

    chunk_id = self._find_relevant_chunk(proposition)

    if chunk_id:
        if self.print_logging:
            print(f"Parça Bulundu ({self.chunks[chunk_id]['chunk_id']}), ekleniyor: {self.chunks[chunk_id]['title']}")
        self.add_proposition_to_chunk(chunk_id, proposition)
        return
    else:
        if self.print_logging:
            print("Parça bulunamadı")
        self._create_new_chunk(proposition)
</code></pre>
    </li>
    <li><code>save_chunks_to_json</code>: İşlenmiş verileri JSON dosyasına kaydeder.
        <pre><code>def save_chunks_to_json(self, file_path: str):
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(self.chunks, f, ensure_ascii=False, indent=4)
</code></pre>
    </li>
</ul>

<h2>Örnek Çıktı</h2>
<p>Çıktı JSON dosyası aşağıdaki yapıya sahip olacaktır:</p>
<pre><code>{
    "b1c36": {
        "chunk_id": "b1c36",
        "propositions": [
            "Kamu Mali Yönetimi ve Kontrol Kanunu, madde kapsamına giren varlıkların maddenin uygulanmasında kullanılacak bilgi ve belgeler ile iade işlemlerine ve uygulamaya ilişkin usul ve esasları belirlemeye yetkilidir."
        ],
        "title": "Kamu Mali Yönetimi ve Kontrol Kanunu'nun Maddeleri",
        "chunk_index": 617,
        "questions": [
            "Kamu Mali Yönetimi ve Kontrol Kanunu hangi konularda yetkilidir?"
        ],
        "answers": [
            "Kamu Mali Yönetimi ve Kontrol Kanunu, madde kapsamına giren varlıkların maddenin uygulanmasında kullanılacak bilgi ve belgeler ile iade işlemlerine ve uygulamaya ilişkin usul ve esasları belirlemeye yetkilidir. Bu kanun aynı zamanda kamu kaynaklarının etkin ve verimli kullanımını sağlamak amacıyla düzenlemeler yapma yetkisine sahiptir."
        ]
    }
}
</code></pre>

<h2>Katkıda Bulunma</h2>
<p>Katkılar memnuniyetle karşılanır! Herhangi bir iyileştirme veya hata düzeltmesi için lütfen bir issue açın veya pull request gönderin.</p>

<h2>Lisans</h2>
<p>Bu proje MIT Lisansı ile lisanslanmıştır. Detaylar için <code>LICENSE</code> dosyasına bakabilirsiniz.</p>

</body>
</html>
