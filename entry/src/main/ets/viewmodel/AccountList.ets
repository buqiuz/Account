import AccountItem from "./AccountItem"
import MethodItem from "./MethodItem"

export const PayList: Array<AccountItem> = [
  {
    icon: $rawfile('foods.svg'),
    accountType: 0,
    typeText: 'foods'
  },
  {
    icon: $rawfile('snacks.svg'),
    accountType: 0,
    typeText: 'snacks'
  },
  {
    icon: $rawfile('fuel.svg'),
    accountType: 0,
    typeText: 'fuel'
  },
  {
    icon: $rawfile('travel.svg'),
    accountType: 0,
    typeText: 'travel'
  },
  {
    icon: $rawfile('games.svg'),
    accountType: 0,
    typeText: 'games'
  },
  {
    icon: $rawfile('pets.svg'),
    accountType: 0,
    typeText: 'pets'
  },
  {
    icon: $rawfile('clothing.svg'),
    accountType: 0,
    typeText: 'clothing'
  },
  {
    icon: $rawfile('utilities.svg'),
    accountType: 0,
    typeText: 'utilities'  // 新增
  },
  {
    icon: $rawfile('shopping.svg'),
    accountType: 0,
    typeText: 'shopping'  // 新增
  }
]

export const EarnList: Array<AccountItem> = [
  {
    icon: $rawfile('income.svg'),
    accountType: 1,
    typeText: 'income'
  },
  {
    icon: $rawfile('invest.svg'),
    accountType: 1,
    typeText: 'invest'
  },
  {
    icon: $rawfile('salary.svg'),
    accountType: 1,
    typeText: 'salary'  // 新增
  },
  {
    icon: $rawfile('bonus.svg'),
    accountType: 1,
    typeText: 'bonus'  // 新增
  }
]

export const MethodList: Array<MethodItem> = [
  {
    icon: $rawfile('wechatPay.svg'),
    typeText: 'wechatPay'
  },
  {
    icon: $rawfile('Alipay.svg'),
    typeText: 'Alipay'
  },
  {
    icon: $rawfile('applePay.svg'),
    typeText: 'applePay'
  },
  {
    icon: $rawfile('googlePay.svg'),
    typeText: 'googlePay'
  },
  {
    icon: $rawfile('card.svg'),  // 新增
    typeText: 'card'  // 新增
  }
]

export const SearchList: Array<MethodItem> = [
  {
    icon: $rawfile('wechatPay.svg'),
    typeText: 'wechatPay'
  },
  {
    icon: $rawfile('Alipay.svg'),
    typeText: 'Alipay'
  },
  {
    icon: $rawfile('applePay.svg'),
    typeText: 'applePay'
  },
  {
    icon: $rawfile('googlePay.svg'),
    typeText: 'googlePay'
  },
  {
    icon: $rawfile('card.svg'),  // 新增
    typeText: 'card'  // 新增
  }
]

export const ImageList: Record<string, Resource> = {
  'foods': $rawfile('foods.svg'),
  'snacks': $rawfile('snacks.svg'),
  'fuel': $rawfile('fuel.svg'),
  'travel': $rawfile('travel.svg'),
  'games': $rawfile('games.svg'),
  'pets': $rawfile('pets.svg'),
  'income': $rawfile('income.svg'),
  'invest': $rawfile('invest.svg'),
  'clothing': $rawfile('clothing.svg'),
  'utilities': $rawfile('utilities.svg'),
  'shopping': $rawfile('shopping.svg'),
  'salary': $rawfile('salary.svg'),
  'bonus': $rawfile('bonus.svg'),
  'wechatPay': $rawfile('wechatPay.svg'),
  'Alipay': $rawfile('Alipay.svg'),
  'applePay': $rawfile('applePay.svg'),
  'googlePay': $rawfile('googlePay.svg'),
  'card': $rawfile('card.svg')  // 新增
}

export const TextList: Record<string, Resource> = {
  'foods': $r('app.string.foods'),
  'snacks': $r('app.string.snacks'),
  'fuel': $r('app.string.fuel'),
  'travel': $r('app.string.travel'),
  'games': $r('app.string.games'),
  'pets': $r('app.string.pets'),
  'income': $r('app.string.income'),
  'invest': $r('app.string.invest'),
  'clothing': $r('app.string.clothing'),
  'utilities': $r('app.string.utilities'),
  'shopping': $r('app.string.shopping'),
  'salary': $r('app.string.salary'),
  'bonus': $r('app.string.bonus'),
  'wechatPay': $r('app.string.wechatPay'),
  'Alipay': $r('app.string.Alipay'),
  'applePay': $r('app.string.applePay'),
  'googlePay': $r('app.string.googlePay'),
  'card': $r('app.string.card')  // 新增
}

export const TextList2: Record<string, string> = {
  'foods': "吃饭",
  'snacks': '零食',
  'fuel': "汽车加油",
  'travel': "旅游",
  'games': "娱乐",
  'pets': "宠物",
  'income': "工作收入",
  'invest': "投资",
  'clothing': "服饰",
  'utilities': "水电气",
  'shopping': "购物",
  'salary': "薪水",
  'bonus': "奖金",
  'wechatPay': "微信",
  'Alipay': "支付宝",
  'applePay': "苹果",
  'googlePay': "谷歌",
  'card': "银联"  // 新增
}

