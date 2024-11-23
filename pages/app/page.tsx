import Link from "next/link";
import Counter from "./test_component"
import { ApiAccess } from "./api_access"

const Home = async () => {
  return (
    <div>
      <h1>Home b3987a9</h1>
      <p>Hello World! This is the Home page</p>
      <p>
        Visit the <Link href="/about">About</Link> page.
      </p>
      <p>
        <Link href="/tmpl/user">User</Link>
      </p>
      <Counter />
      <ApiAccess />
    </div>
  );
};

export default Home;
