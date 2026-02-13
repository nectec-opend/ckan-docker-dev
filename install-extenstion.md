# วิธีติดตั้ง CKAN Extensions เพิ่มเติม ในสภาพแวดล้อมการพัฒนา CKAN Thai GDC

docker exec -it ckan-dev bash

cd src_extensions

# install ckanext-geoview
git clone --branch v0.2.2 https://github.com/ckan/ckanext-geoview.git

# install ckanext-xloader
git clone https://gitlab.nectec.or.th/opend/ckanext-xloader.git

# install ckanext-pdfview
git clone --branch 0.0.8 https://github.com/ckan/ckanext-pdfview.git

# install ckanext-dcat
git clone --branch v2.3.0 https://github.com/ckan/ckanext-dcat.git

# install ckanext-scheming 
git clone --branch release-3.1.0 https://github.com/ckan/ckanext-scheming.git

# install ckanext-hierarchy
git clone --branch v1.2.2 https://github.com/ckan/ckanext-hierarchy.git

# install ckanext-opendstats
git clone --branch dev-py3 https://gitlab.nectec.or.th/opend/ckanext-opendstats.git

# install ckanext-showcase
git clone https://gitlab.nectec.or.th/opend/dev-python3/ckanext-showcase.git

# install ckanext-thai_gdc
git clone https://gitlab.nectec.or.th/opend/ckanext-thai_gdc.git


# ออกจาก docker exec ckan-dev
exit

# แก้ไขไฟล์ .env ** uncomment 

# รัน docker compose up สำหรับ service ckan อีกครั้ง
docker compose up -d ckan

# ดู log ของ container ckan-dev
docker logs -f ckan-dev






