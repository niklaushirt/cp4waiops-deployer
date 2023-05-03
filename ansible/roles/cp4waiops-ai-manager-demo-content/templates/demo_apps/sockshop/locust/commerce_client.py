import random
from locust import HttpUser, task, between
from util import AuthorizedClient

# Load test of a "realistic" scenario simulating a client that browses for
# products, adds some of them to their basket, and regularly makes a purchase.
# This simulates activity across the entire SockShop application.
class CommerceClient(AuthorizedClient):
    wait_time = between(1, 5)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # The default product id if no browsing has been performed yet
        self.product_id = "3395a43e-2d88-40de-b95f-e00e1502085b"

    @task(5)
    def browse_all(self):
        # This is the trace of requests we have recorded when opening the
        # catalogue
        self.client.get("/category.html")
        self.client.get("/topbar.html")
        self.client.get("/navbar.html")
        self.client.get("/footer.html")
        self.client.get("/catalogue/size?tags=", name="/catalogue/size")
        self.client.get("/tags")
        self.client.get("/cart")
        self.client.get("/customers/me")

        products = self.client.get("/catalogue?page=1&size=9&tags=", name="/catalogue?size=9")
        product_list = products.json()
        if len(product_list) > 0:
            product_number = random.randrange(len(product_list))
            self.product_id = product_list[product_number]["id"]

    @task(10)
    def browse(self):
        # This is the trace of requests we have recorded when viewing details
        # on a specific product
        self.client.get(f"/detail.html?id={self.product_id}", name="/detail.html")
        self.client.get("/topbar.html")
        self.client.get("/navbar.html")
        self.client.get("/footer.html")

        item_detail = self.client.get(f"/catalogue/{self.product_id}", name="/catalogue/{product_id}")
        tags = item_detail.json()["tag"]
        tag = ""
        if len(tags) > 0:
            tag = tags[0]

        self.client.get("/customers/me")
        self.client.get("/cart")
        self.client.get(f"/catalogue?sort=id&size=3&tags={tag}", name="/catalogue?size=3")

    @task(7)
    def add_to_basket(self):
        # This is the trace of requests we have recorded when adding a product
        # to the cart
        self.client.post("/cart", json={
            "id": self.product_id,
        })
        self.client.get(f"/detail.html?id={self.product_id}", name="/detail.html")
        self.client.get("/topbar.html")
        self.client.get("/navbar.html")
        self.client.get("/footer.html")

        item_detail = self.client.get(f"/catalogue/{self.product_id}", name="/catalogue/{product_id}")
        tags = item_detail.json()["tag"]
        tag = ""
        if len(tags) > 0:
            tag = tags[0]

        self.client.get("/customers/me")
        self.client.get("/cart")
        self.client.get(f"/catalogue?sort=id&size=3&tags={tag}", name="/catalogue?size=3")
        self.client.get(f"/catalogue/{self.product_id}", name="/catalogue/{product_id}")

    @task(5)
    def purchase(self):
        # This is the trace of requests we have recorded when opening the
        # basket
        self.client.get("/basket.html")
        self.client.get("/topbar.html")
        self.client.get("/navbar.html")
        self.client.get("/footer.html")
        self.client.get("/cart")
        self.client.get("/card")
        self.client.get("/address")
        self.client.get("/catalogue?size=3")
        self.client.get(f"/catalogue/{self.product_id}", name="/catalogue/{product_id}")
        self.client.get("/customers/me")
        self.client.get("/cart")
        self.client.get(f"/catalogue/{self.product_id}", name="/catalogue/{product_id}")

        # This is the trace of requests we have recorded when proceeding to
        # checkout
        self.client.post("/orders")
        self.client.delete("/cart")
        self.client.get("/customer-orders.html?", name="/customer-orders.html")
        self.client.get("/topbar.html")
        self.client.get("/navbar.html")
        self.client.get("/footer.html")
        self.client.get("/orders")
        self.client.get("/cart")
        self.client.get("/customers/me")
