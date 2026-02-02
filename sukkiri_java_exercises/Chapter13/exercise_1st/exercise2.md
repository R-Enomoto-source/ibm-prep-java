int recovPoint = (int)(basePoint * this.wand.**power**); // 杖による増幅
原因はこのpowerによるもの。
エラーの内容はprivateでアクセス制限のあるものに、powerでアクセスしようとして生まれている。
