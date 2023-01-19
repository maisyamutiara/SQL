#periksa missing values
SELECT count(*) AS null_count
FROM schoters.transaksi
WHERE harga_asli IS NULL OR harga_asli = '';

#handling missing values dengan menghapus row null
DELETE FROM schoters.transaksi
WHERE harga_asli IS NULL;

#periksa missing values setelah penghapusan row null
SELECT count(*) AS null_count
FROM schoters.transaksi
WHERE harga_asli IS NULL;

#membuat tabel keseluruhan
CREATE TABLE schoters.result AS
SELECT schoters.campaign.name AS campaign, 
schoters.campaign.start_date AS start_date,
schoters.campaign.end_date AS end_date,
schoters.transaksi.tanggal_transaksi AS tanggal,
schoters.transaksi.nama_sales AS sales,
schoters.transaksi.harga_asli AS harga,
schoters.transaksi.customer AS customer,
schoters.transaksi.tipe_produk AS produk,
schoters.customer.nama AS nama,
schoters.customer.domisili AS domisili,
schoters.customer.usia AS usia
FROM schoters.transaksi
INNER JOIN schoters.customer 
ON customer=nama
INNER JOIN schoters.campaign
ON schoters.transaksi.tanggal_transaksi BETWEEN start_date AND end_date
ORDER BY tanggal ASC;

#total transaksi dari masing-masing customer
SELECT schoters.result.customer,
	count(*) AS customer_transaksi,
    CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
    CONCAT('Rp', FORMAT(AVG(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS mean_transaksi
FROM schoters.result
GROUP BY customer
ORDER BY customer ASC;

#total transaksi dari masing-masing kota
SELECT schoters.result.domisili,
	count(*) AS kota_transaksi,
    CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
    CONCAT('Rp', FORMAT(AVG(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS mean_transaksi
FROM schoters.result
GROUP BY domisili
ORDER BY domisili ASC;

#Exploratory Data Analysis
#Banyak customer yang dikumpulkan masing-masing sales
SELECT schoters.result.sales,
	count(*) AS jumlah_customer,
	CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
    CONCAT('Rp', FORMAT(AVG(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS mean_transaksi
FROM schoters.result
GROUP BY sales
ORDER BY sales ASC;

#Pengaruh campaign terhadap jumlah customer
SELECT schoters.result.campaign,
	count(*) AS jumlah_customer,
	CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
    CONCAT('Rp', FORMAT(AVG(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS mean_transaksi
FROM schoters.result
GROUP BY campaign
ORDER BY campaign ASC;

#Produk yang paling banyak terjual
SELECT schoters.result.produk,
	count(*) AS jumlah_customer,
	CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
    CONCAT('Rp', FORMAT(AVG(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS mean_transaksi
FROM schoters.result
GROUP BY produk
ORDER BY produk ASC;

#Mengelompokkan usia customer
SELECT
CASE
    WHEN usia < 17 THEN 'Anak-Anak'
    WHEN usia BETWEEN 17 and 30 THEN 'Remaja'
    WHEN usia BETWEEN 30 and 50 THEN 'Dewasa'
    WHEN usia >= 50 THEN 'Lansia'
    WHEN usia IS NULL THEN 'Not Filled In (NULL)'
END as range_usia,
COUNT(*) AS jumlah
FROM schoters.result
GROUP BY range_usia
ORDER BY range_usia;

#Hitung selisih total transaksi dengan budget
SELECT schoters.result.campaign,
    CONCAT('Rp', FORMAT(SUM(CAST(REPLACE(RIGHT(harga, LENGTH(harga)-2), ',','') AS decimal)),2,'id_ID')) AS total_transaksi,
	CONCAT('Rp', FORMAT(CAST(REPLACE(RIGHT(budget, LENGTH(budget)-2), ',','') AS decimal),2,'id_ID')) AS budget_transaksi
FROM schoters.result
INNER JOIN schoters.campaign ON schoters.result.campaign = schoters.campaign.name
GROUP BY campaign
ORDER BY campaign ASC;

#Daerah berdasarkan produk
SELECT schoters.result.domisili, schoters.result.produk,
COUNT(DISTINCT tanggal) AS total_produk
FROM schoters.result
GROUP BY domisili, produk
ORDER BY domisili ASC;

#Pembelian produk terbanyak berdasarkan customer
SELECT schoters.result.customer, schoters.result.produk, COUNT(tanggal) AS jumlah_transaksi 
FROM schoters.result
WHERE schoters.result.customer = 'Mygneo' OR schoters.result.customer = 'Bzayan'
GROUP BY customer,produk
ORDER BY customer ASC;