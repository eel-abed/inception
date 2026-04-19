# User Documentation (USER_DOC.md)

This document explains, in clear and simple terms, how an end user or administrator can interact with the deployed infrastructure.

## 1. Services Provided by the Stack
This infrastructure provides a functional web stack consisting of three main services working together:
*   **Web Server (NGINX):** Analyzes incoming traffic from the internet, ensures the connection is secure (HTTPS using TLS protocols), and displays the website securely.
*   **Website Engine (WordPress):** The content management system (CMS) that contains the blog's code (PHP). It processes all the requests sent by NGINX.
*   **Database (MariaDB):** Securely stores all the website data, user profiles, posts, and configurations. It is not accessible from the generic web, only from the WordPress engine.

## 2. Start and Stop the Project
All the complex orchestration logic is wrapped inside a simpler controller sequence.

*   **To Start:** Open a terminal in the root folder, type:
    ```bash
    make all
    ```
    This will configure everything automatically and start the services in the background.

*   **To Stop:** Open your terminal and type:
    ```bash
    make down
    ```
    This safely shuts down your infrastructure without losing your data.

## 3. Access the Website and the Administration Panel
Once started, you can browse your site smoothly. You will encounter a security warning stating the connection is not private—this is perfectly normal as the security certificate was created locally by us instead of a paid external authority. Simply click **Advanced Settings** and then **Proceed/Continue**.

*   **View the Website:** Type this URL in your browser: `https://eel-abed.42.fr:4443`
*   **Manage the Website:** To write posts or edit themes, go to the Admin Dashboard: `https://eel-abed.42.fr:4443/wp-admin`

## 4. Locate and Manage Credentials
To ensure total security, there are no passwords hardcoded globally.
*   Before launching for the first time, all passwords and names are securely defined inside a `.env` file typically located in the `srcs/` folder.
*   Once configured by the server administrator, you must use the credentials (Admin username and Admin password) stored within that file to log into the `/wp-admin` WordPress panel.

## 5. Check That the Services are Running Correctly
To ensure everything is operational as an administrator:
1.  Open your terminal in the application project root.
2.  Type `docker ps` to display process statuses.
3.  You should firmly see three components (`nginx`, `wordpress`, `mariadb`) with the `STATUS` displaying `Up`.
4.  Navigate to `https://eel-abed.42.fr:4443`, if the site successfully loads, everything is functional!
