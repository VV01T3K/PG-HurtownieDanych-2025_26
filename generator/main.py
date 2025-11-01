from faker import Faker
import pandas as pd
from faker.providers import BaseProvider
import random


fake = Faker()

print(fake.name())
print(fake.email())
print(fake.address())
print(fake.date_of_birth(minimum_age=18, maximum_age=90))
print(fake.text(max_nb_chars=120))

fake = Faker("en_US")  # e.g., "de_DE", "fr_FR", "ja_JP"
print(fake.name())
print(fake.phone_number())


# from faker import Faker

Faker.seed(12345)
fake = Faker()
print(fake.name())  # same across runs with the same seed


fake = Faker()


def make_user():
    return {
        "id": fake.uuid4(),
        "name": fake.name(),
        "email": fake.unique.email(),
        "signup_at": fake.date_time_between("-2y", "now").isoformat(),
        "address": {
            "street": fake.street_address(),
            "city": fake.city(),
            "zip": fake.postcode(),
            "country": fake.country(),
        },
    }


users = [make_user() for _ in range(5)]
print(users)


# from faker import Faker

fake = Faker()
rows = [
    {
        "name": fake.name(),
        "email": fake.unique.email(),
        "dob": fake.date_of_birth(minimum_age=18, maximum_age=80),
        "salary": fake.pydecimal(left_digits=5, right_digits=2, positive=True),
    }
    for _ in range(1000)
]
df = pd.DataFrame(rows)
df.to_csv("fake_users.csv", index=False)


class MyProvider(BaseProvider):
    def product_code(self):
        return f"PRD-{random.randint(100000, 999999)}"


fake = Faker()
fake.add_provider(MyProvider)

print(fake.product_code())
