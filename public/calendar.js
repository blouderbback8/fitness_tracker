document.addEventListener("DOMContentLoaded", () => {
    const plannerDateInput = document.getElementById("planner-date");
    const plannerForm = document.getElementById("day-planner-form");
    const activityDropdown = document.getElementById("planner-activity");

    // Auto-select today's date
    const today = new Date().toISOString().split("T")[0];
    plannerDateInput.value = today;

    // Function to add an activity to the calendar
    function addToCalendar(name, date) {
        const targetDay = document.querySelector(`.calendar-day[data-date="${date}"]`);
        if (targetDay) {
            const activityItem = document.createElement("div");
            activityItem.className = "activity-entry";
            activityItem.innerHTML = `<strong>${name}</strong>`;

            // Apply color styling based on activity type
            if (name === "Jiu-Jitsu") {
                activityItem.style.backgroundColor = "#007bff";
            } else if (name === "Alcohol") {
                activityItem.style.backgroundColor = "#dc3545";
            } else if (["Fast Food", "Dessert"].includes(name)) {
                activityItem.style.backgroundColor = "#ffcc00";
            } else {
                activityItem.style.backgroundColor = "#28a745";
            }

            activityItem.style.padding = "4px";
            activityItem.style.borderRadius = "4px";
            activityItem.style.color = "white";
            activityItem.style.fontSize = "12px";
            activityItem.style.marginTop = "3px";
            activityItem.style.textAlign = "center";
            activityItem.style.cursor = "pointer";

            // Add right-click delete event
            activityItem.addEventListener("contextmenu", (event) => {
                event.preventDefault();
                activityItem.remove();
            });

            targetDay.appendChild(activityItem);
        } else {
            console.error(`No calendar day found for date: ${date}`);
        }
    }

    // Handle form submission
    plannerForm.addEventListener("submit", (event) => {
        event.preventDefault();
        const selectedDate = plannerDateInput.value;
        const selectedActivity = activityDropdown.value;

        // Get the next day's date
        let nextDay = new Date(selectedDate);
        nextDay.setDate(nextDay.getDate() + 1);
        let nextDayName = nextDay.toLocaleString('en-us', { weekday: 'long' });

        if (selectedActivity === "Alcohol" && (nextDayName === "Monday" || nextDayName === "Wednesday" || nextDayName === "Friday")) {
            // Hide the day planner and show the warning video
            document.body.innerHTML = 
                <div class="video-container">
                    <h2>Warning!</h2>
                    <video width="600" controls autoplay>
                        <source src="/No_Alcohol_Before_BJJ.mp4" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                    <br>
                    <button onclick="location.reload()">Go Back</button>
                </div>
            ;
            return;
        }

        // If the rule is followed, add the activity to the calendar
        addToCalendar(selectedActivity, selectedDate);
    });
});
