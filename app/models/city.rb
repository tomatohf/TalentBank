class City < HashModel::Grouped
  
  def self.data
    # {
    #   province_id => [
    #     {:id => city_id, :name => city_name}
    #   ]
    # }
    
    {
      10 => [
        {:id => 10, :name => "上海"}
      ],
      
      
      20 => [
        {:id => 20, :name => "北京"}
      ],
      
      
      30 => [
        {:id => 30, :name => "广州"},
        {:id => 40, :name => "深圳"},
        {:id => 50, :name => "珠海"},
        {:id => 60, :name => "汕头"},
        {:id => 70, :name => "韶关"},
        {:id => 80, :name => "佛山"},
        {:id => 90, :name => "江门"},
        {:id => 100, :name => "湛江"},
        {:id => 110, :name => "茂名"},
        {:id => 120, :name => "肇庆"},
        {:id => 130, :name => "惠州"},
        {:id => 140, :name => "梅州"},
        {:id => 150, :name => "汕尾"},
        {:id => 160, :name => "河源"},
        {:id => 170, :name => "阳江"},
        {:id => 180, :name => "清远"},
        {:id => 190, :name => "东莞"},
        {:id => 200, :name => "中山"},
        {:id => 210, :name => "潮州"},
        {:id => 220, :name => "揭阳"},
        {:id => 230, :name => "云浮"},
        {:id => 240, :name => "从化"}
      ],
      
      
      40 => [
        {:id => 250, :name => "合肥"},
        {:id => 260, :name => "芜湖"},
        {:id => 270, :name => "蚌埠"},
        {:id => 280, :name => "淮南"},
        {:id => 290, :name => "马鞍山"},
        {:id => 300, :name => "淮北"},
        {:id => 310, :name => "铜陵"},
        {:id => 320, :name => "安庆"},
        {:id => 330, :name => "黄山"},
        {:id => 340, :name => "滁州"},
        {:id => 350, :name => "阜阳"},
        {:id => 360, :name => "宿州"},
        {:id => 370, :name => "巢湖"},
        {:id => 380, :name => "六安"},
        {:id => 390, :name => "亳州"},
        {:id => 400, :name => "宣城"},
        {:id => 410, :name => "池州"}
      ],
      
      
      50 => [
        {:id => 420, :name => "重庆"}
      ],
      
      
      60 => [
        {:id => 430, :name => "福州"},
        {:id => 440, :name => "厦门"},
        {:id => 450, :name => "莆田"},
        {:id => 460, :name => "三明"},
        {:id => 470, :name => "泉州"},
        {:id => 480, :name => "漳州"},
        {:id => 490, :name => "南平"},
        {:id => 500, :name => "龙岩"},
        {:id => 510, :name => "宁德"}
      ],
      
      
      70 => [
        {:id => 520, :name => "兰州"},
        {:id => 530, :name => "金昌"},
        {:id => 540, :name => "白银"},
        {:id => 550, :name => "天水"},
        {:id => 560, :name => "嘉峪关"},
        {:id => 570, :name => "武威"},
        {:id => 580, :name => "张掖"},
        {:id => 590, :name => "平凉"},
        {:id => 600, :name => "酒泉"},
        {:id => 610, :name => "庆阳"},
        {:id => 620, :name => "定西"},
        {:id => 630, :name => "陇南"},
        {:id => 640, :name => "临夏"},
        {:id => 650, :name => "甘南"}
      ],
      
      
      80 => [
        {:id => 660, :name => "南宁"},
        {:id => 670, :name => "柳州"},
        {:id => 680, :name => "桂林"},
        {:id => 690, :name => "梧州"},
        {:id => 700, :name => "北海"},
        {:id => 710, :name => "防城港"},
        {:id => 720, :name => "钦州"},
        {:id => 730, :name => "贵港"},
        {:id => 740, :name => "玉林"},
        {:id => 750, :name => "百色"},
        {:id => 760, :name => "贺州"},
        {:id => 770, :name => "河池"},
        {:id => 780, :name => "来宾"},
        {:id => 790, :name => "崇左"}
      ],
      
      
      90 => [
        {:id => 800, :name => "贵阳"},
        {:id => 810, :name => "六盘水"},
        {:id => 820, :name => "遵义"},
        {:id => 830, :name => "安顺"},
        {:id => 840, :name => "铜仁"},
        {:id => 850, :name => "毕节"},
        {:id => 860, :name => "黔西南"},
        {:id => 870, :name => "黔东南"},
        {:id => 880, :name => "黔南"}
      ],
      
      
      100 => [
        {:id => 890, :name => "海口"},
        {:id => 900, :name => "东方"},
        {:id => 910, :name => "定安"},
        {:id => 920, :name => "屯昌"},
        {:id => 930, :name => "澄迈"},
        {:id => 940, :name => "临高"},
        {:id => 950, :name => "西南中沙群岛"},
        {:id => 960, :name => "白沙"},
        {:id => 970, :name => "昌江"},
        {:id => 980, :name => "乐东"},
        {:id => 990, :name => "陵水"},
        {:id => 1000, :name => "保亭"},
        {:id => 1010, :name => "琼中"},
        {:id => 1020, :name => "三亚"},
        {:id => 1030, :name => "五指山"},
        {:id => 1040, :name => "琼海"},
        {:id => 1050, :name => "儋州"},
        {:id => 1060, :name => "文昌"},
        {:id => 1070, :name => "万宁"}
      ],
      
      
      110 => [
        {:id => 1080, :name => "石家庄"},
        {:id => 1090, :name => "唐山"},
        {:id => 1100, :name => "秦皇岛"},
        {:id => 1110, :name => "邯郸"},
        {:id => 1120, :name => "邢台"},
        {:id => 1130, :name => "保定"},
        {:id => 1140, :name => "张家口"},
        {:id => 1150, :name => "承德"},
        {:id => 1160, :name => "沧州"},
        {:id => 1170, :name => "廊坊"},
        {:id => 1180, :name => "衡水"}
      ],
      
      
      120 => [
        {:id => 1190, :name => "郑州"},
        {:id => 1200, :name => "开封"},
        {:id => 1210, :name => "洛阳"},
        {:id => 1220, :name => "平顶山"},
        {:id => 1230, :name => "安阳"},
        {:id => 1240, :name => "鹤壁"},
        {:id => 1250, :name => "新乡"},
        {:id => 1260, :name => "焦作"},
        {:id => 1270, :name => "濮阳"},
        {:id => 1280, :name => "许昌"},
        {:id => 1290, :name => "漯河"},
        {:id => 1300, :name => "三门峡"},
        {:id => 1310, :name => "南阳"},
        {:id => 1320, :name => "商丘"},
        {:id => 1330, :name => "信阳"},
        {:id => 1340, :name => "周口"},
        {:id => 1350, :name => "驻马店"},
        {:id => 1360, :name => "济源"}
      ],
      
      
      130 => [
        {:id => 1370, :name => "哈尔滨"},
        {:id => 1380, :name => "齐齐哈尔"},
        {:id => 1390, :name => "鹤岗"},
        {:id => 1400, :name => "双鸭山"},
        {:id => 1410, :name => "鸡西"},
        {:id => 1420, :name => "大庆"},
        {:id => 1430, :name => "伊春"},
        {:id => 1440, :name => "牡丹江"},
        {:id => 1450, :name => "佳木斯"},
        {:id => 1460, :name => "七台河"},
        {:id => 1470, :name => "黑河"},
        {:id => 1480, :name => "绥化"},
        {:id => 1490, :name => "大兴安岭"}
      ],
      
      
      140 => [
        {:id => 1500, :name => "武汉"},
        {:id => 1510, :name => "宜昌"},
        {:id => 1520, :name => "十堰"},
        {:id => 1530, :name => "荆州"},
        {:id => 1540, :name => "黄石"},
        {:id => 1550, :name => "襄樊"},
        {:id => 1560, :name => "鄂州"},
        {:id => 1570, :name => "荆门"},
        {:id => 1580, :name => "孝感"},
        {:id => 1590, :name => "黄冈"},
        {:id => 1600, :name => "咸宁"},
        {:id => 1610, :name => "随州"},
        {:id => 1620, :name => "恩施"},
        {:id => 1630, :name => "仙桃市"},
        {:id => 1640, :name => "天门市"},
        {:id => 1650, :name => "潜江市"},
        {:id => 1660, :name => "神农架"}
      ],
      
      
      150 => [
        {:id => 1670, :name => "长沙"},
        {:id => 1680, :name => "株洲"},
        {:id => 1690, :name => "湘潭"},
        {:id => 1700, :name => "衡阳"},
        {:id => 1710, :name => "邵阳"},
        {:id => 1720, :name => "岳阳"},
        {:id => 1730, :name => "常德"},
        {:id => 1740, :name => "张家界"},
        {:id => 1750, :name => "益阳"},
        {:id => 1760, :name => "郴州"},
        {:id => 1770, :name => "永州"},
        {:id => 1780, :name => "怀化"},
        {:id => 1790, :name => "娄底"},
        {:id => 1800, :name => "湘西"}
      ],
      
      
      160 => [
        {:id => 1810, :name => "南京"},
        {:id => 1820, :name => "张家港"},
        {:id => 1830, :name => "无锡"},
        {:id => 1840, :name => "徐州"},
        {:id => 1850, :name => "常州"},
        {:id => 1860, :name => "苏州"},
        {:id => 1870, :name => "南通"},
        {:id => 1880, :name => "连云港"},
        {:id => 1890, :name => "淮安"},
        {:id => 1900, :name => "盐城"},
        {:id => 1910, :name => "扬州"},
        {:id => 1920, :name => "镇江"},
        {:id => 1930, :name => "泰州"},
        {:id => 1940, :name => "宿迁"},
        {:id => 1950, :name => "太仓"}
      ],
      
      
      170 => [
        {:id => 1960, :name => "南昌"},
        {:id => 1970, :name => "景德镇"},
        {:id => 1980, :name => "萍乡"},
        {:id => 1990, :name => "九江"},
        {:id => 2000, :name => "新余"},
        {:id => 2010, :name => "鹰潭"},
        {:id => 2020, :name => "赣州"},
        {:id => 2030, :name => "吉安"},
        {:id => 2040, :name => "宜春"},
        {:id => 2050, :name => "抚州"},
        {:id => 2060, :name => "上饶"}
      ],
      
      
      180 => [
        {:id => 2070, :name => "长春"},
        {:id => 2080, :name => "吉林"},
        {:id => 2090, :name => "四平"},
        {:id => 2100, :name => "辽源"},
        {:id => 2110, :name => "通化"},
        {:id => 2120, :name => "白山"},
        {:id => 2130, :name => "松原"},
        {:id => 2140, :name => "白城"},
        {:id => 2150, :name => "延边"}
      ],
      
      
      190 => [
        {:id => 2160, :name => "沈阳"},
        {:id => 2170, :name => "大连"},
        {:id => 2180, :name => "鞍山"},
        {:id => 2190, :name => "抚顺"},
        {:id => 2200, :name => "本溪"},
        {:id => 2210, :name => "丹东"},
        {:id => 2220, :name => "锦州"},
        {:id => 2230, :name => "营口"},
        {:id => 2240, :name => "阜新"},
        {:id => 2250, :name => "辽阳"},
        {:id => 2260, :name => "盘锦"},
        {:id => 2270, :name => "铁岭"},
        {:id => 2280, :name => "朝阳"},
        {:id => 2290, :name => "葫芦岛"}
      ],
      
      
      200 => [
        {:id => 2300, :name => "呼和浩特"},
        {:id => 2310, :name => "包头"},
        {:id => 2320, :name => "乌海"},
        {:id => 2330, :name => "赤峰"},
        {:id => 2340, :name => "通辽"},
        {:id => 2350, :name => "鄂尔多斯"},
        {:id => 2360, :name => "呼伦贝尔"},
        {:id => 2370, :name => "巴彦淖尔"},
        {:id => 2380, :name => "巴彦淖尔"},
        {:id => 2390, :name => "乌兰察布"},
        {:id => 2400, :name => "锡林郭勒"},
        {:id => 2410, :name => "兴安"},
        {:id => 2420, :name => "阿拉善"}
      ],
      
      
      210 => [
        {:id => 2430, :name => "银川"},
        {:id => 2440, :name => "石嘴山"},
        {:id => 2450, :name => "吴忠"},
        {:id => 2460, :name => "固原"},
        {:id => 2470, :name => "中卫"}
      ],
      
      
      220 => [
        {:id => 2480, :name => "西宁"},
        {:id => 2490, :name => "海东"},
        {:id => 2500, :name => "海北"},
        {:id => 2510, :name => "黄南"},
        {:id => 2520, :name => "海南"},
        {:id => 2530, :name => "果洛"},
        {:id => 2540, :name => "玉树"},
        {:id => 2550, :name => "海西"}
      ],
      
      
      230 => [
        {:id => 2560, :name => "济南"},
        {:id => 2570, :name => "淄博"},
        {:id => 2580, :name => "青岛"},
        {:id => 2590, :name => "枣庄"},
        {:id => 2600, :name => "东营"},
        {:id => 2610, :name => "烟台"},
        {:id => 2620, :name => "潍坊"},
        {:id => 2630, :name => "济宁"},
        {:id => 2640, :name => "泰安"},
        {:id => 2650, :name => "威海"},
        {:id => 2660, :name => "日照"},
        {:id => 2670, :name => "莱芜"},
        {:id => 2680, :name => "临沂"},
        {:id => 2690, :name => "德州"},
        {:id => 2700, :name => "聊城"},
        {:id => 2710, :name => "滨州"},
        {:id => 2720, :name => "菏泽"}
      ],
      
      
      240 => [
        {:id => 2730, :name => "太原"},
        {:id => 2740, :name => "大同"},
        {:id => 2750, :name => "阳泉"},
        {:id => 2760, :name => "长治"},
        {:id => 2770, :name => "晋城"},
        {:id => 2780, :name => "朔州"},
        {:id => 2790, :name => "晋中"},
        {:id => 2800, :name => "运城"},
        {:id => 2810, :name => "忻州"},
        {:id => 2820, :name => "临汾"},
        {:id => 2830, :name => "吕梁"}
      ],
      
      
      250 => [
        {:id => 2840, :name => "西安"},
        {:id => 2850, :name => "铜川"},
        {:id => 2860, :name => "宝鸡"},
        {:id => 2870, :name => "咸阳"},
        {:id => 2880, :name => "渭南"},
        {:id => 2890, :name => "延安"},
        {:id => 2900, :name => "汉中"},
        {:id => 2910, :name => "榆林"},
        {:id => 2920, :name => "安康"},
        {:id => 2930, :name => "商洛"}
      ],
      
      
      260 => [
        {:id => 2940, :name => "成都"},
        {:id => 2950, :name => "阿坝"},
        {:id => 2960, :name => "甘孜"},
        {:id => 2970, :name => "凉山"},
        {:id => 2980, :name => "巴中"},
        {:id => 2990, :name => "德阳"},
        {:id => 3000, :name => "广安"},
        {:id => 3010, :name => "广元"},
        {:id => 3020, :name => "眉山"},
        {:id => 3030, :name => "达州"},
        {:id => 3040, :name => "资阳"},
        {:id => 3050, :name => "乐山"},
        {:id => 3060, :name => "泸州"},
        {:id => 3070, :name => "绵阳"},
        {:id => 3080, :name => "南充"},
        {:id => 3090, :name => "内江"},
        {:id => 3100, :name => "攀枝花"},
        {:id => 3110, :name => "遂宁"},
        {:id => 3120, :name => "雅安"},
        {:id => 3130, :name => "宜宾"},
        {:id => 3140, :name => "自贡"}
      ],
      
      
      270 => [
        {:id => 3150, :name => "天津"}
      ],
      
      
      280 => [
        {:id => 3160, :name => "拉萨"},
        {:id => 3170, :name => "阿里"},
        {:id => 3180, :name => "昌都"},
        {:id => 3190, :name => "林芝"},
        {:id => 3200, :name => "那曲"},
        {:id => 3210, :name => "日喀则"},
        {:id => 3220, :name => "山南"}
      ],
      
      
      290 => [
        {:id => 3230, :name => "乌鲁木齐"},
        {:id => 3240, :name => "巴音郭楞"},
        {:id => 3250, :name => "阿拉尔"},
        {:id => 3260, :name => "图木舒克"},
        {:id => 3270, :name => "五家渠"},
        {:id => 3280, :name => "阿克苏"},
        {:id => 3290, :name => "阿勒泰"},
        {:id => 3300, :name => "昌吉"},
        {:id => 3310, :name => "哈密"},
        {:id => 3320, :name => "和田"},
        {:id => 3330, :name => "喀什"},
        {:id => 3340, :name => "克拉玛依"},
        {:id => 3350, :name => "克孜勒苏"},
        {:id => 3360, :name => "博尔塔拉"},
        {:id => 3370, :name => "石河子"},
        {:id => 3380, :name => "塔城"},
        {:id => 3390, :name => "吐鲁番"},
        {:id => 3400, :name => "伊犁"}
      ],
      
      
      300 => [
        {:id => 3410, :name => "昆明"},
        {:id => 3420, :name => "红河"},
        {:id => 3430, :name => "德宏"},
        {:id => 3440, :name => "怒江"},
        {:id => 3450, :name => "迪庆"},
        {:id => 3460, :name => "保山"},
        {:id => 3470, :name => "楚雄"},
        {:id => 3480, :name => "大理"},
        {:id => 3490, :name => "临沧"},
        {:id => 3500, :name => "丽江"},
        {:id => 3510, :name => "曲靖"},
        {:id => 3520, :name => "文山"},
        {:id => 3530, :name => "西双版纳"},
        {:id => 3540, :name => "玉溪"},
        {:id => 3550, :name => "昭通"},
        {:id => 3560, :name => "普洱"}
      ],
      
      
      310 => [
        {:id => 3570, :name => "杭州"},
        {:id => 3580, :name => "宁波"},
        {:id => 3590, :name => "温州"},
        {:id => 3600, :name => "嘉兴"},
        {:id => 3610, :name => "湖州"},
        {:id => 3620, :name => "舟山"},
        {:id => 3630, :name => "金华"},
        {:id => 3640, :name => "丽水"},
        {:id => 3650, :name => "衢州"},
        {:id => 3660, :name => "绍兴"},
        {:id => 3670, :name => "台州"}
      ],
      
      
      320 => [
        {:id => 3680, :name => "香港"}
      ],
      
      
      330 => [
        {:id => 3690, :name => "澳门"}
      ],
      
      
      340 => [
        {:id => 3700, :name => "台湾"}
      ],
      
      
      350 => [
        {:id => 0, :name => "美国"},
        {:id => 0, :name => "英国"},
        {:id => 0, :name => "法国"},
        {:id => 0, :name => "德国"},
        {:id => 0, :name => "韩国"},
        {:id => 0, :name => "日本"},
        {:id => 0, :name => "其他国家"}
      ]
    }
  end
  
end