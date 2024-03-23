# multi-party-lottery
เริ่ม contract มาเป็น stage 1 สามารถใช function addUser ได้ โดยจะเป็นการ add เข้าไปในระบบพร้อมกับ commit ค่า transaction ที่จะเล่นด้วยกันเลย
เมื่อเลยเวลา T1 แล้วสามารถเรียก function advanceStage ไปยัง stage ถัดไปได้ หรือถ้าคนครบ N คนแล้วจะไป stage 2 โดยอัตโนมัติ
เข้าสู่ stage 2 user ทุกคนทำการ reveal ค่าที่ commit ไปเมื่อ stage ที่แล้วด้วยฟังชั่น revealUser หาก reveal ครบทุกคนจะไป stage 3 โดยอัตโนมัติ หรือเมื่อเลยเวลา T2 สามารถเรียก function advanceStage ไปยัง stage ถัดไปได้
เข้าสู่ stage 3 owner ทำการสุ่มผู้ชนะด้วยฟังชั่น findWinner เมื่อเลยเวลา T3 แล้ว user ไม่ได้เงินสักทีสามารถเรียก function advanceStage ไปยัง stage ถัดไปได้ จากนั้นสามารถเรียก function refund ให้ตัวเองได้
