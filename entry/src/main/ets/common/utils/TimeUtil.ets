export class TimeUtil {
  formatTime(dateString: string): string {
    let date = new Date(dateString); // 将传入的日期字符串转换为 Date 对象
    let hours = date.getHours(); // 获取小时部分
    let minutes = date.getMinutes(); // 获取分钟部分

    // 格式化为 "HH:mm" 形式，确保分钟部分有前导零
    return `${hours}:${minutes < 10 ? '0' + minutes : minutes}`;
  }

  formatMonthDay(dateString: string): string {
    let date = new Date(dateString); // 将传入的日期字符串转换为 Date 对象
    let month = date.getMonth() + 1; // 获取月份（0-11），加 1 转换为 1-12
    let day = date.getDate(); // 获取日期（1-31）

    // 格式化为 "MM-dd" 形式，确保月份和日期有前导零
    return `${month < 10 ? '0' + month : month}-${day < 10 ? '0' + day : day}`;
  }

  getWeekday(dateString: string): string {
    let date = new Date(dateString); // 将传入的日期字符串转换为 Date 对象
    let dayOfWeek = date.getDay(); // 获取星期几（0-6，0为星期天，6为星期六）
    
    // 星期名称数组
    let weekdays = ["星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
    return weekdays[dayOfWeek]; // 返回对应的星期名称
  }

  // 新增：获取年-月-日格式
  formatYearMonthDay(dateString: string): string {
    let date = new Date(dateString); // 将传入的日期字符串转换为 Date 对象
    let year = date.getFullYear(); // 获取年份
    let month = date.getMonth() + 1; // 获取月份（0-11），加 1 转换为 1-12
    let day = date.getDate(); // 获取日期（1-31）

    // 格式化为 "YYYY-MM-DD" 形式，确保月份和日期有前导零
    return `${year}-${month < 10 ? '0' + month : month}-${day < 10 ? '0' + day : day}`;
  }

  // 新增：获取年-月格式
  formatYearMonth(dateString: string): string {
    let date = new Date(dateString); // 将传入的日期字符串转换为 Date 对象
    let year = date.getFullYear(); // 获取年份
    let month = date.getMonth() + 1; // 获取月份（0-11），加 1 转换为 1-12

    // 格式化为 "YYYY-MM" 形式，确保月份有前导零
    return `${year}-${month < 10 ? '0' + month : month}`;
  }
}
