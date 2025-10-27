import os
import sys
import unittest

# Ensure project root is on sys.path so `from app import app` works when running tests directly
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from app import health

# Prevent heavy models from loading during tests
os.environ["SKIP_MODEL_LOADING"] = "1"




class HealthTest(unittest.TestCase):
    def test_health_function(self):
        result = health()
        self.assertIsInstance(result, dict)
        self.assertEqual(result.get("status"), "ok")

    def test_health(self):
        pass  # Placeholder for the original test method, can be removed if not needed


if __name__ == "__main__":
    unittest.main()
