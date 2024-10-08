// app.js
import express from 'express';
import db from './db.js';

const app = express();
app.use(express.json());

// --------- User CRUD Operations ---------

// Create a new user
app.get('/', async (req, res) => {
    try {
        const [result] = await db.query('SELECT * FROM login');
        console.log(result);
    } catch (error) {
        res.status(500).send(error);
    }
});

//check username password and usertype
app.post('/login', async (req, res) => {
    try {
        const [result] = await db.query('SELECT * FROM login WHERE username = ? AND password = ?', [req.body.username, req.body.password]);
        if (result.length > 0) {
            res.json(result[0]);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error);
    }
})

app.get('/room-information/:username', async (req, res) => {
    const { username } = req.params;
    console.log('Username:', username);
    // Validate that the username is provided
    if (!username) {
        return res.status(400).json({ error: 'Username is required' });
    }

    try {
        const query = `
            SELECT 
                login.username,
                information.name,
                information.surname,
                room.roomname,
                bill.room_id,
                bill.bill_id,
                bill.room_charge,
                bill.water_charge,
                bill.electricity_charge,
                bill.garbage_charge,
                bill.other_charge,
                bill.payment_status,
                bill.bill_url
            
            FROM 
                login
            JOIN 
                information ON login.id = information.login_id
            JOIN 
                room ON login.id = room.roommember
            JOIN 
                bill ON room.id = bill.room_id
            WHERE 
                login.username = ?;
        `;

        const [result] = await db.query(query, [username]);

        if (result.length > 0) {
            res.json(result[result.length - 1]);  // Return the room information
        } else {
            res.status(404).json({ error: 'User or room information not found' });
        }
    } catch (error) {
        console.error('Error fetching room information:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});


//update bills
app.post("/update_bills", async (req, res) => {
    const { bill_id, bill_link } = req.body;

    // Ensure both fields are provided
    if (!bill_id || !bill_link) {
        return res.status(400).json({ error: 'Bill ID and Bill Link are required' });
    }

    const payment_status = 1;

    try {
        // Begin a transaction
        await db.beginTransaction();

        // Check if the bill already exists
        const [check_bill_url] = await db.query('SELECT bill_url FROM bill WHERE bill_id = ?', [bill_id]);

        if (check_bill_url.length > 0) {
            // Bill exists, update it
            await db.query('UPDATE bill SET payment_status = ?, bill_url = ? WHERE bill_id = ?', [payment_status, bill_link, bill_id]);
            await db.commit();  // Commit the transaction
            res.json({ message: 'Bill updated successfully' });
        } else {
            // Bill doesn't exist, insert it
            await db.query('INSERT INTO bill (bill_id, bill_url, payment_status) VALUES (?, ?, ?)', [bill_id, bill_link, payment_status]);
            await db.commit();  // Commit the transaction
            res.json({ message: 'New bill inserted successfully' });
        }
    } catch (error) {
        await db.rollback();  // Rollback transaction in case of error
        console.error('Error updating or inserting bill:', error);  // Log the error internally
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.get("/getAllRooms", async (req, res) => {

    try {
        const query = `
            SELECT 
                information.name,
                information.surname,
                room.roomname,
                room.roommember,
                room.id,
                room.description
            FROM 
                login
            JOIN 
                information ON login.id = information.login_id
            JOIN 
                room ON room.roommember = information.login_id
        `;

        // Execute the query with the provided username
        const [result] = await db.query(query);

        if (result.length > 0) {
            res.json(result);  // Return the first matching user room info
        } else {
            res.status(404).json({ error: 'User not found or no room information available' });
        }
    } catch (error) {
        console.error('Error fetching user room info:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.get("/getBillbyRoom/:room_id", async (req, res) => {
    const { room_id } = req.params;

    // Ensure the room_id is provided
    if (!room_id) {
        return res.status(400).json({ error: 'Room ID is required' });
    }

    try {
        const query = `
            SELECT 
                *
            FROM 
                bill
            WHERE 
                bill.room_id = ?
            ORDER BY bill.bill_id DESC;
        `;

        // Execute the query with the provided room_id
        const [result] = await db.query(query, [room_id]);

        if (result.length > 0) {
            res.json(result);  // Return the first matching bill info
        } else {
            res.status(404).json({ error: 'Billing information not found for the specified room' });
        }
    } catch (error) {
        console.error('Error fetching bill info:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});
// new bill
app.post("/newBill", async (req, res) => {

    const { room_id, room_charge, water_charge, electricity_charge, garbage_charge, other_charge } = req.body;

    if (!room_id || !room_charge || !electricity_charge || !water_charge || !garbage_charge || !other_charge) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    try {

        const query = `
            INSERT INTO bill 
            (room_id, room_charge, water_charge, electricity_charge, garbage_charge, other_charge, payment_status)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        `;

        const [result] = await db.query(query, [room_id, room_charge, water_charge, electricity_charge, garbage_charge, other_charge, 0]);
        res.status(201).json({ message: 'Bill inserted successfully', result });

    } catch (error) {
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.get('/getBillById/:bill_id', async (req, res) => {
    const { bill_id } = req.params;

    if (!bill_id) {
        return res.status(400).json({ error: 'Bill ID is required' });
    }

    try {
        const query = `SELECT * FROM bill WHERE bill_id = ?`;

        const [result] = await db.query(query, [bill_id]);
        if (result.length > 0) {
            res.json(result);
        } else {
            res.status(404).json({ error: 'Bill not found' });
        }
    } catch (error) {
        res.status(500).json({ error: 'Internal Server Error' });
    }
})

app.put('/update_billbyId', async (req, res) => {
    const {
        bill_id,
        room_charge,
        water_charge,
        electricity_charge,
        garbage_charge,
        other_charge,
        payment_status,
        bill_url
    } = req.body;

    // Validate input
    if (!bill_id || !room_charge || !water_charge || !electricity_charge || !garbage_charge || !other_charge || !payment_status || !bill_url) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    try {
        // SQL query to update the bill
        const query = `
            UPDATE bill
            SET 
                room_charge = ?,
                water_charge = ?,
                electricity_charge = ?,
                garbage_charge = ?,
                other_charge = ?,
                payment_status = ?,
                bill_url = ?
            WHERE 
                bill_id = ?;
        `;

        // Execute the query with provided values
        const [result] = await db.query(query, [
            room_charge,
            water_charge,
            electricity_charge,
            garbage_charge,
            other_charge,
            payment_status,
            bill_url,
            bill_id
        ]);

        if (result.affectedRows > 0) {
            res.json({ message: 'Bill updated successfully' });
        } else {
            res.status(404).json({ error: 'Bill not found' });
        }
    } catch (error) {
        console.error('Error updating bill:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.delete('/delete_bill/:bill_id', async (req, res) => {
    const { bill_id } = req.params;

    // Validate input
    if (!bill_id) {
        return res.status(400).json({ error: 'Bill ID is required' });
    }

    try {
        // SQL query to delete the bill by bill_id
        const query = `
            DELETE FROM bill
            WHERE bill_id = ?;
        `;

        // Execute the query with the provided bill_id
        const [result] = await db.query(query, [bill_id]);

        if (result.affectedRows > 0) {
            res.json({ message: 'Bill deleted successfully' });
        } else {
            res.status(404).json({ error: 'Bill not found' });
        }
    } catch (error) {
        console.error('Error deleting bill:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});



// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});