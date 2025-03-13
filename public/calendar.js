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
            
            // Add right-click delete event
            activityItem.addEventListener("contextmenu", (event) => {
                event.preventDefault(); // Prevents default right-click menu
                activityItem.remove();  // Deletes the activity
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

        // Prevent alcohol logging before Jiu-Jitsu days (Monday, Wednesday, Friday)
        if (["Monday", "Wednesday", "Friday"].includes(nextDayName) && selectedActivity === "Alcohol") {
            alert("🚫 Alcohol is not allowed because the next day is a Jiu-Jitsu day!");
            return; // Stop the submission
        }

        // If the rule is followed, add the activity to the calendar
        addToCalendar(selectedActivity, selectedDate);
    });
});
