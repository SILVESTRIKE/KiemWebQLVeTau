using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using NUnit.Framework;
using System;
using System.IO;

namespace SecurityTests
{
    [TestFixture]
    public class BasicTest
    {
        private IWebDriver driver;
        private string baseUrl = "http://localhost:53258"; // Cập nhật URL đúng ở đây

        [SetUp]
        public void SetUp()
        {
            var options = new ChromeOptions();
            options.AddArgument("--ignore-certificate-errors");
            driver = new ChromeDriver(options);
            driver.Manage().Window.Maximize();
        }

        [TearDown]
        public void TearDown()
        {
            // Chụp ảnh màn hình nếu test thất bại
            if (TestContext.CurrentContext.Result.Outcome.Status == NUnit.Framework.Interfaces.TestStatus.Failed)
            {
                string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                string testName = TestContext.CurrentContext.Test.Name;
                string fileName = $"{testName}_{timestamp}.png";
                
                try
                {
                    ((ITakesScreenshot)driver).GetScreenshot().SaveAsFile(fileName);
                    TestContext.WriteLine($"Đã lưu ảnh màn hình thất bại: {fileName}");
                }
                catch (Exception e)
                {
                    TestContext.WriteLine($"Không thể lưu ảnh màn hình: {e.Message}");
                }
            }
            
            driver?.Quit();
            driver?.Dispose();
        }

        [Test]
        public void VerifyHomePageLoads()
        {
            driver.Navigate().GoToUrl(baseUrl);
            
            // Ghi lại URL hiện tại và tiêu đề trang
            TestContext.WriteLine($"Trang đã tải: {driver.Url}");
            TestContext.WriteLine($"Tiêu đề trang: {driver.Title}");
            
            // Hiển thị tất cả các phần tử có thể nhìn thấy để kiểm tra cấu trúc
            var elements = driver.FindElements(By.TagName("a"));
            TestContext.WriteLine($"Số lượng liên kết trên trang: {elements.Count}");
            
            foreach (var element in elements)
            {
                try 
                {
                    TestContext.WriteLine($"Link: {element.Text} - Href: {element.GetAttribute("href")}");
                }
                catch (Exception) 
                {
                    // Bỏ qua nếu không thể đọc thông tin liên kết
                }
            }
            
            // Ghi lại cấu trúc trang đăng nhập
            try
            {
                driver.Navigate().GoToUrl($"{baseUrl}/TaiKhoan/DangNhap");
                TestContext.WriteLine("==== Trang đăng nhập ====");
                TestContext.WriteLine($"URL: {driver.Url}");
                
                var inputs = driver.FindElements(By.TagName("input"));
                foreach (var input in inputs)
                {
                    try
                    {
                        string id = input.GetAttribute("id") ?? "không có ID";
                        string name = input.GetAttribute("name") ?? "không có name";
                        string type = input.GetAttribute("type") ?? "không có type";
                        
                        TestContext.WriteLine($"Input - ID: {id}, Name: {name}, Type: {type}");
                    }
                    catch (Exception)
                    {
                        // Bỏ qua nếu không thể đọc thuộc tính
                    }
                }
                
                var buttons = driver.FindElements(By.TagName("button"));
                foreach (var button in buttons)
                {
                    try
                    {
                        TestContext.WriteLine($"Button: {button.Text}, Type: {button.GetAttribute("type")}");
                    }
                    catch (Exception)
                    {
                        // Bỏ qua nếu không thể đọc thuộc tính
                    }
                }
            }
            catch (Exception ex)
            {
                TestContext.WriteLine($"Không thể truy cập trang đăng nhập: {ex.Message}");
            }
        }
    }
} 