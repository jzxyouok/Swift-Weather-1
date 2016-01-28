//
//  ViewController.swift
//  雨燕天气
//
//  Created by k&r on 16/1/27.
//  Copyright © 2016年 k&r. All rights reserved.
//

import UIKit

struct WeatherStruct {     //使用struct比class初始化更方便
  var city :String?
  var temp :String?
  var weather :String?
}

class ViewController: UIViewController {

  @IBOutlet weak var City: UILabel!
  @IBOutlet weak var Temp: UILabel!
  @IBOutlet weak var Weather: UILabel!
  
  var weatherData: WeatherStruct? {
    didSet {           //计数属性，发生变化时更新界面didSet方法
      configView()
    }
  }
  
  func configView() {
  //程序启动时刷新天气，配置界面方法
    City.text = self.weatherData?.city
    Temp.text = self.weatherData?.temp
    Weather.text = self.weatherData?.weather
  }
 

  //iOS8下标准的NSURLSession，建立一整套的网络连接
  func getWeatherData() {
    //网址
    let url = NSURL(string: "http://api.k780.com:88/?app=weather.today&weaid=645&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json")
    
    //会话配置，默认超时连接时1min
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.timeoutIntervalForRequest = 10  //超时设成10s
    
    //建立会话，设置NSURL配置
    let session = NSURLSession(configuration: config)
    
    //会话的任务
    let task = session.dataTaskWithURL(url!) { (data, _, error) -> Void in    //dataTaskWithRequest异步执行，返回之后会通知可进行下一步操作
      
      if error == nil {   //如果连接没有错误则处理数据
/*
        //解析方法1⃣️：抛出错误，但错误不处理
       let json1: NSDictionary?
        do {
          json1 = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
          print(json1)
        } catch _ {
          json1 = nil
          print("错误")
        }    
*/
        //解析方法2⃣️：try！不抛出错误
        do {
          if let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary { //使用if let强制转换成字典
            //print(json)
            //把JSON对象，直接实例话为自定义对象
            let weatherInfo = (json.valueForKey("result") as? NSDictionary).map { WeatherStruct(city: $0["citynm"] as? String, temp: $0["temperature_curr"] as? String, weather: $0["weather"] as? String)
            }     //map映射成对象，map只有一个参数。映射调研weatherStruc初始化，取出字典，强制转换为参数值
            
            //把更新界面的线程放到主线程,凡事根UI有关的都放到主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.weatherData = weatherInfo   //对视图属性进行设置
              
//  另一个直接解析的方法
 /*           let weatherInfo = json.valueForKey("result")
            let city = weatherInfo?.valueForKey("citynm")
            self.City.text = "\(city!)"
            let temp = weatherInfo?.valueForKey("temp_curr")
            self.Temp.text = "\(temp!)"
            let weather = weatherInfo?.valueForKey("weather")
            self.Weather.text = "\(weather!)" */
            })
          }
        }

      } else { print("getWeatherData 错误")}
    }

    //任务执行
    task.resume()
  }

  
  enum JSONError: String, ErrorType {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
  }
  
  func jsonParser() {
    let urlPath = "http://api.k780.com:88/?app=weather.today&weaid=645&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json"
    guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
    let request = NSMutableURLRequest(URL:endpoint)
    NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
      do {
        guard let dat = data else { throw JSONError.NoData }
        guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
        //以下为添加
        print(json)
        let weatherInfo = (json.valueForKey("result") as? NSDictionary).map { WeatherStruct(city: $0["citynm"] as? String, temp: $0["temperature_curr"] as? String, weather: $0["weather"] as? String)
        }     //map映射成对象，map只有一个参数。映射调研weatherStruc初始化，取出字典，强制转换为参数值
        
        //把更新界面的线程放到主线程,凡事根UI有关的痘放到主线程
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.weatherData = weatherInfo   //对视图属性进行设置
        })
        //以上为添加
      } catch let error as JSONError {
        print(error.rawValue)
      } catch {
        print(error)
      }
      }.resume()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    getWeatherData()   //不进行错误处理方法
//    jsonParser()     //进行错误处理方法
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

