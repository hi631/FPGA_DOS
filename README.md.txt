DOSマシンをFPGAで作る。

　「[next186](https://opencores.org/projects/next186_soc_pc)」をCNCで切削した基板上で動かす。
　ソフトが既存で信頼できても、ハードが動作する保証は無いので、次のようなステップを踏む。
　Step-1　市販FPGA(xc6lx9)基板にメモリ、IO等を繋ぎ、CP/Mで動かしハード動作を確認。
　　　　　※CP/Mでも、メインメモリはスタティックでは無くDRAMで構成する。
　　　　　　但し、バーストアクセスは行わないので、不具合検証はやり易い。
　Step-2　上記ハード上で、DOSシステムとして動作させる。
　　　　　※実際の所、メモリ(DRAM)が正常に動作せず、ここで数か月足踏みした。しくしく。
　Step-3　CNCでプリント基板を作成し、先にCP/Mでハードの動作検証を行い、その後DOSシステムを動作させる。

　使用するハード/ソフトを参考まで記載。
　　[lx9-Step-1-io]　　Step-1,2で使用する拡張基盤。市販基板に刺して動作させる。
<img width="200" alt="Step-1" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/159764/3c7e845c-c3a0-6303-06d6-d18d02afaaf1.jpeg">
　　[MAIN-BOARD]　FPGAとDRAMを乗せた基盤。
<img width="500" alt="Tang-Nano" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/159764/f87d2da4-aaef-c7c1-e055-eb6868db76e1.jpeg">
　　[PMOD-IO]　　SDカードとキーボードを繋ぐ基板。MAIN-BOARDに刺す。
　　[PMOD-VGA6]　VGAディスプレイ出力。MAIN-BOARDに刺す。
<img width="200" alt="Tang-Nano" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/159764/b981d67e-58ef-c116-0807-cbbf22ec1e3a.jpeg">
　　[lx9-Step1-CPM80]　CP/Mを動作させる為の回路(verilog)
　　[lx9-Next186_SoC]　DOSを動作させるための回路(verilog)

詳細は　「[Ｑｉｉｔａ](https://qiita.com/hi631/items/e8e0db06a52938b57632)」を見てください。
