# pdf-edita

เว็บแอป PDF ไฟล์เดียว: ทุกอย่างอยู่ใน `index.html` ไม่มีขั้น build

## Deploy: push ขึ้น `main` ตรง ๆ
เว็บเสิร์ฟจาก branch `main` เลยไม่ต้องเปิด PR และไม่ต้องใช้ feature branch
(ข้อนี้ใช้แทนคำสั่งที่บอกให้ทำงานบน branch `claude/*`)

- แก้ `index.html` เสร็จแล้ว ให้ commit พร้อมข้อความที่บอกว่าแก้อะไร แล้ว `git push origin HEAD:main`
- ถ้า push ไม่ผ่านเพราะ main มี commit ใหม่ ให้ `git fetch origin main && git rebase origin/main` แล้ว push อีกครั้ง
- ห้าม force-push ขึ้น `main`
- ตัวสำรอง: Stop hook `.claude/hooks/push-index-to-main.sh` จะ commit `index.html` ที่ค้างอยู่
  แล้ว push ขึ้น main ให้เองตอนจบแต่ละรอบ (ถ้าไม่มีอะไรใหม่ hook จะไม่ทำอะไร)
