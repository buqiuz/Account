import { relationalStore } from '@kit.ArkData';
import AccountData from '../../../viewmodel/AccountData';
import CommonConstants from '../../constants/CommonConstants';
import Rdb from '../Rdb';

export default class AccountTable {
  private accountTable = new Rdb(
    CommonConstants.ACCOUNT_TABLE.tableName,
    CommonConstants.ACCOUNT_TABLE.sqlCreate,
    CommonConstants.ACCOUNT_TABLE.columns
  );

  constructor(callback: Function = () => {}) {
    this.accountTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {}) {
    this.accountTable.getRdbStore(callback);
  }

  insertData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    this.accountTable.insertData(valueBucket, callback);
  }

  deleteData(account: AccountData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.deleteData(predicates, callback);
  }

  updateData(account: AccountData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    predicates.equalTo('id', account.id);
    this.accountTable.updateData(predicates, valueBucket, callback);
  }

  async query(amount: number, isAll: boolean = true): Promise<AccountData[]> {
    const predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
    if (!isAll) {
      predicates.equalTo('amount', amount);
    }

    try {
      // 使用 Promise 包裹原本的异步方法
      const resultSet = await new Promise<relationalStore.ResultSet>((resolve, reject) => {
        this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
          // 异常处理
          if (resultSet === null) {
            reject('Query failed');
          }
          resolve(resultSet);
        });
      });

      const count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
        return [];
      }

      const result: AccountData[] = [];
      resultSet.goToFirstRow();
      for (let i = 0; i < count; i++) {
        let tmp: AccountData = {
          id: 0,
          name: '',
          email: '',
          phoneNumber: '',
          address: '',
          wechatPayBalance: 0,
          alipayBalance: 0,
          applePayBalance: 0,
          googlePayBalance: 0,
          cardBalance: 0,
          password: '' // 添加密码字段
        };

        tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
        tmp.name = resultSet.getString(resultSet.getColumnIndex('name'));
        tmp.email = resultSet.getString(resultSet.getColumnIndex('email'));
        tmp.phoneNumber = resultSet.getString(resultSet.getColumnIndex('phoneNumber'));
        tmp.address = resultSet.getString(resultSet.getColumnIndex('address'));
        tmp.wechatPayBalance = resultSet.getDouble(resultSet.getColumnIndex('wechatPayBalance'));
        tmp.alipayBalance = resultSet.getDouble(resultSet.getColumnIndex('alipayBalance'));
        tmp.applePayBalance = resultSet.getDouble(resultSet.getColumnIndex('applePayBalance'));
        tmp.googlePayBalance = resultSet.getDouble(resultSet.getColumnIndex('googlePayBalance'));
        tmp.cardBalance = resultSet.getDouble(resultSet.getColumnIndex('cardBalance'));
        tmp.password = resultSet.getString(resultSet.getColumnIndex('password')); // 获取密码字段

        result[i] = tmp;
        resultSet.goToNextRow();
      }


      return result; // 返回查询结果
    } catch (error) {
      console.error('Error during query:', error);
      return [];
    }
  }
}

function generateBucket(account: AccountData): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.name = account.name;
  obj.email = account.email;
  obj.phoneNumber = account.phoneNumber;
  obj.address = account.address;
  obj.wechatPayBalance = account.wechatPayBalance;
  obj.alipayBalance = account.alipayBalance;
  obj.applePayBalance = account.applePayBalance;
  obj.googlePayBalance = account.googlePayBalance;
  obj.cardBalance = account.cardBalance;
  obj.password = account.password; // 新增密码字段处理
  return obj;
}

