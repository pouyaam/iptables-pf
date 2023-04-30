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
