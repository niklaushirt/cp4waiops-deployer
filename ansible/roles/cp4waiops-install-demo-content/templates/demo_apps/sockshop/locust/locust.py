import base64

from locust import HttpUser, TaskSet, task
from random import randint, choice


class WebTasks(HttpUser):

    @task
    def load(self):
        base64string = 'dXNlcjpwYXNzd29yZAo='
        #base64.encodebytes('%s:%s' % ('user', 'password')).replace('\n', '')

        self.client.get("/")
        self.client.get("/catalogue")
        self.client.get("/catalogue/03fef6ac-1896-4ce8-bd69-b798f85c6e0b")
        self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
        self.client.get("/category.html")
        self.client.get("/detail.html?id=03fef6ac-1896-4ce8-bd69-b798f85c6e0b")
        self.client.delete("/cart")
        self.client.post("/cart", json={"id": "03fef6ac-1896-4ce8-bd69-b798f85c6e0b", "quantity": 1})
        self.client.get("/basket.html")
        self.client.post("/orders")

        # catalogue = self.client.get("/catalogue").json()
        # category_item = choice(catalogue)
        # item_id = category_item["id"]

