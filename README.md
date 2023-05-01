# GOST

به منظور فعال سازی با GOST مراحل زیر را طی کنید

۱- اول با دستور زیر نرم افزار GOST را نصب کنید

``` bash
sudo apt install wget nano -y && wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz && gunzip gost-linux-amd64-2.11.5.gz
```

۲- سپس دستور زیر را وارد کنید

``` bash
sudo mv gost-linux-amd64-2.11.5 /usr/local/bin/gost && sudo chmod +x /usr/local/bin/gost
```

۳- بعد فایل کانفیگ را با دستور زیر باز کنید

``` bash
sudo nano /usr/lib/systemd/system/gost.service
```

۴- سپس کانفیگ زیر را کپی کنید، بجای mtnn.ircf.space میتونید دامین یا IP خودتون رو وارد کنید
```
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -L=tcp://:443/mtnn.ircf.space:443 -L=tcp://:80/mtnn.ircf.space:80

[Install]
WantedBy=multi-user.target
```

سپس با زدن CTRL+X و Y فایل مورد نظر را سیو کنید

۵- با دستور زیر GOST رو اجرا کنید

``` bash
sudo systemctl start gost && systemctl enable gost
```



# iptables-pf
این اسکریپت به منظور فعال سازی Port Forwarding با iptables ساخته شده

---

۱- با دستور زیر اول اسکریپت را داخل سرور خود نصب کنید

``` bash
wget -N --no-check-certificate https://raw.githubusercontent.com/pouyaam/iptables-pf/main/iptables-pf.sh && chmod +x iptables-pf.sh && bash iptables-pf.sh
```
۲- سپس با انتخاب گزینه 1 اول از نصب شدن iptables و فعال شدن Port forwarding اطمینان حاصل کنید

۳- سپس با دستور زیر اجرا کنید دوباره اسکریپت
``` bash
bash iptables-pf.sh
```
۴- سپس گزینه ۴ را انتخاب کرده

۵- سپس پورت مورد نظر که روی IP که مدنظر هست بنویسید، مثال 443

۶- سپس IP مورد نظر که باید Port Forwarding انجام شود را وارد کنید، مثال 95.179.160.40

۷- سپس از شما پرسیده می شود که چه پورتی باید روی سرور شما باز شود، که می‌توانید خالی بزارید 

۸- سپس IP سرور شما پرسیده می‌شود که اگر خالی بزارید بطور اتوماتیک IP سرور خودتون تشخیص داده می‌شود

۹- در نهایت از شما تاییدیه کانفیگ نهایی گرفته می‌شود که Enter بزنید

درنهایت Port forwarding مشخص برای شما فعال می‌شود

