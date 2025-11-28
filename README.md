<div align="center">
  <img src="/static/logo.png" width=130px, height=130px>
  <h3>NetScope</h3>
  <p>iOS приложение для сканирования Bluetooth и LAN устройств</p>
  <p>
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5.0">
    <img src="https://img.shields.io/badge/Platform-iOS%2015%2B-blue.svg" alt="Platform iOS 15+">
    <img src="https://img.shields.io/badge/Architecture-MVVM%20-brightgreen" alt="Architecture MVVM">
    <img src="https://img.shields.io/badge/UI-SwiftUI%20-blueviolet.svg" alt="UI SwiftUI">
    <img src="https://img.shields.io/badge/Dependencies-SPM-green.svg" alt="SPM">
  </p>
  <p>
    <img src="https://img.shields.io/badge/Database-CoreData-orange" alt="CoreData">
    <img src="https://img.shields.io/badge/Animation-Lottie%20-yellow" alt="Animation">
  </p>
<div>

---

<div align="left">
  <h3>О проекте</h3>
  <p>
    <b>NetScope</b> - тестовое приложение, разработанное для компании <b>Aezakmi Group</b>. В техническом задании требовалось использовать библиотеку <a href="https://cocoapods.org/pods/LANScanner">LanScan</a> для сканирования локальной сети. 
    Однако библиотека давно не обновлялась и вызывала проблемы при интеграции. Я мог бы исправить внутреннюю логику LanScan, но посчитал это неоправданными трудозатратами. Вместо этого я реализовал сканирование LAN-сети 
    самостоятельно — функциональность оказалась вполне решаемой без сторонних зависимостей. Также созданы unit тесты для services и viewModels
  </p>
  <hr>
  <h3>Скрины</h3>
</div>


| <img src="static/screen_1.PNG" width="200"/> | <img src="static/screen_2.PNG" width="200"/> | <img src="static/screen_3.PNG" width="200"/> | <img src="static/screen_4.PNG" width="200"/> |
|--------|--------|--------|--------|
| <img src="static/screen_5.PNG" width="200"/> | <img src="static/screen_6.PNG" width="200"/> | <img src="static/screen_7.PNG" width="200"/> | <img src="static/screen_8.PNG" width="200"/> |

<div align="left">
  <h3>Структура</h3>

  <pre>
    NetScope/
    ├── App/              # Entry point
    ├── Models/           # Data models
    ├── ViewModels/       # Business logic
    ├── Views/            # SwiftUI views
    ├── Services/         # BT/LAN scanning
    └── Persistence/      # CoreData stack
  </pre>

  <h3>Установка</h3>
  <pre>
    Переходим в репо: https://github.com/Yuldshev/NetScope
    Нажимаем Code → Open with Xcode → Указываем путь клонирования репо
  </pre>
</div>

