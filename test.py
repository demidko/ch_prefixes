import convert as app
import unittest

class ConvertTestCase(unittest.TestCase):

    def test_foo(self):
        input = '2019-12-25T00:01:06.720066+10:00 baza.farpost.ru_log: "baza.drom.ru" 188.162.15.218 - - [25/Dec/2019:00:01:06 +1000] "GET /mmy.txt?action=viewbull_object_on_map&keyName=1&_=1577210355889 HTTP/1.1" "200" "0" "1374" "0.000" 192.168.36.22 "-" "-" "0xfb6ce9" "54bf28d40354094e0be213d7220d8757" "-" "-" "-" "https://baza.drom.ru/novosibirsk/service/service/oformlenie-izmenenija-konstrukcii-i-pereoborudovanija-ts-60762064.html" "Mozilla/5.0 (Linux; Android 8.1.0; DRA-LX5 Build/HUAWEIDRA-LX5; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/67.0.3396.87 Mobile Safari/537.36 BazaDromAndroidApp/51" "on" "-" "-" "-" "" "" "192.168.36.128" "80.92.164.142" "7.3.10" "-" "-"'
        csv = app.convert(input)
        self.assertEqual(
            csv,
            ["2019-12-25 00:01:06", 16477417, "54bf28d40354094e0be213d7220d8757", "viewbull_object_on_map", 1.0,
            "[(\'keyName\',\'1\')]"])


if __name__ == "__main__":
    unittest.main()